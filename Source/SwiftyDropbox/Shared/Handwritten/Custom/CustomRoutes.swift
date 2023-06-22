///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation

// 24 MB file chunk size
let fileChunkSize: UInt64 = 24 * 1_024 * 1_024
let timeoutInSec = 200

extension FilesRoutes {
    @discardableResult public func batchUploadFiles(
        fileUrlsToCommitInfo: [URL: Files.CommitInfo],
        queue: DispatchQueue? = nil,
        progressBlock: ProgressBlock? = nil,
        responseBlock: @escaping BatchUploadResponseBlock
    ) -> BatchUploadTask? {
        if client.isBackgroundClient {
            fatalError("batch upload is not supported for background clients")
        }

        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("FilesRoutes.batchUploadFiles")
            .appendingPathComponent(UUID().uuidString)

        let responseQueue = queue ?? DispatchQueue.main

        var copiedFileUrlPairsToCommitInfo: [BatchUploadData.UrlPair: Files.CommitInfo]

        do {
            copiedFileUrlPairsToCommitInfo = try copyUrlsToTempDirectory(tempDirectory: tempDirectory, fileUrlsToCommitInfo: fileUrlsToCommitInfo)
        } catch {
            DropboxClientsManager.log(.error, "Error creating batch upload temp directory: \(error.localizedDescription)")
            responseQueue.async {
                responseBlock(nil, .clientError(.clientError(.fileAccessError(error))), [:])
                self.cleanUpTempDirectory(tempDirectory: tempDirectory)
            }
            return nil
        }

        let uploadData = BatchUploadData(
            fileCommitInfo: copiedFileUrlPairsToCommitInfo,
            tempDirectoryUrl: tempDirectory,
            progressBlock: progressBlock,
            responseBlock: responseBlock,
            queue: responseQueue
        )
        let uploadTask = BatchUploadTask(uploadData: uploadData)

        let fileUrlPairs: [BatchUploadData.UrlPair] = Array(uploadData.fileUrlPairsToCommitInfo.keys)

        var fileUrlPairsToFileSize: [BatchUploadData.UrlPair: UInt64] = [:]
        var totalUploadSize: UInt64 = 0
        // determine total upload size for progress handler
        for fileUrlPair in fileUrlPairs {
            var fileSize: UInt64

            do {
                let attr = try FileManager.default.attributesOfItem(atPath: fileUrlPair.copiedUrl.path)
                fileSize = attr[FileAttributeKey.size] as? UInt64 ?? 0
                totalUploadSize += fileSize
                fileUrlPairsToFileSize[fileUrlPair] = fileSize
            } catch {
                uploadData.queue.async {
                    let clientError: ClientError = .fileAccessError(error)
                    uploadData.responseBlock(nil, nil, [fileUrlPair.callerUrl: .clientError(.clientError(clientError))])
                    self.cleanUpTempDirectory(tempDirectory: uploadData.tempDirectoryUrl)
                }
                return uploadTask
            }
        }

        uploadData.totalUploadProgress = Progress(totalUnitCount: Int64(totalUploadSize))

        for fileUrlPair in fileUrlPairs {
            guard let fileSize = fileUrlPairsToFileSize[fileUrlPair] else { continue }
            if !uploadData.cancel {
                if fileSize < fileChunkSize {
                    // file is small, so we won't chunk upload it.
                    startUploadSmallFile(uploadData: uploadData, fileUrlPair: fileUrlPair, fileSize: fileSize)
                } else {
                    // file is somewhat large, so we will chunk upload it, repeatedly querying
                    // `/upload_session/append_v2` until the file is uploaded
                    startUploadLargeFile(uploadData: uploadData, fileUrlPair: fileUrlPair, fileSize: fileSize)
                }
            } else {
                break
            }
        }
        // small or large, we query `upload_session/finish_batch` to batch commit
        // uploaded files.
        batchFinishUponCompletion(uploadData: uploadData)
        return uploadTask
    }

    func startUploadSmallFile(uploadData: BatchUploadData, fileUrlPair: BatchUploadData.UrlPair, fileSize: UInt64) { // this is the copied URL
        uploadData.uploadGroup.enter()
        // immediately close session after first API call
        // because file can be uploaded in one request

        let request = uploadSessionStart(close: true, input: fileUrlPair.copiedUrl).response(queue: uploadData.queue, completionHandler: { result, error in
            if let result = result, let commitInfo = uploadData.fileUrlPairsToCommitInfo[fileUrlPair] {
                let sessionId = result.sessionId
                let offset = fileSize
                let cursor = Files.UploadSessionCursor(sessionId: sessionId, offset: offset)
                let finishArg = Files.UploadSessionFinishArg(cursor: cursor, commit: commitInfo)
                // store commit info for this file
                uploadData.finishArgs.append(finishArg)
            } else if let error = error {
                uploadData.fileUrlPairsToRequestErrors[fileUrlPair] = .startError(error)
            }
            uploadData.startRequests[fileUrlPair] = nil
            uploadData.uploadGroup.leave()
        }).progress { progress in
            self.executeProgressHandler(uploadData: uploadData, progress: progress)
        }
        uploadData.startRequests[fileUrlPair] = request
    }

    func startUploadLargeFile(uploadData: BatchUploadData, fileUrlPair: BatchUploadData.UrlPair, fileSize: UInt64) {
        uploadData.uploadGroup.enter()
        let startBytes = 0
        let endBytes = fileChunkSize
        let fileChunkInputStream = ChunkInputStream(fileUrl: fileUrlPair.copiedUrl, startBytes: startBytes, endBytes: Int(endBytes))
        // use seperate continue upload queue so we don't block other files from
        // commencing their upload
        let chunkUploadContinueQueue = DispatchQueue(label: "chunk_upload_continue_queue")
        // do not immediately close session

        let request = uploadSessionStart(input: fileChunkInputStream).response(queue: chunkUploadContinueQueue, completionHandler: { result, error in
            if let result = result, let commitInfo = uploadData.fileUrlPairsToCommitInfo[fileUrlPair] {
                let sessionId = result.sessionId
                self.appendRemainingFileChunks(uploadData: uploadData, fileUrlPair: fileUrlPair, fileSize: fileSize, sessionId: sessionId)
                let cursor = Files.UploadSessionCursor(sessionId: sessionId, offset: fileSize)
                let finishArg = Files.UploadSessionFinishArg(cursor: cursor, commit: commitInfo)
                // Store commit info for this file
                uploadData.finishArgs.append(finishArg)
            } else if let error = error {
                uploadData.fileUrlPairsToRequestErrors[fileUrlPair] = .startError(error)
                uploadData.uploadGroup.leave()
            }
            uploadData.startRequests[fileUrlPair] = nil
        }).progress { progress in
            progress.totalUnitCount = Int64(endBytes)
            self.executeProgressHandler(uploadData: uploadData, progress: progress)
        }

        uploadData.startRequests[fileUrlPair] = request
    }

    func appendRemainingFileChunks(uploadData: BatchUploadData, fileUrlPair: BatchUploadData.UrlPair, fileSize: UInt64, sessionId: String) {
        // use seperate response queue so we don't block response thread
        // with dispatch_semaphore_t
        let chunkUploadResponseQueue = DispatchQueue(label: "chunk_upload_response_queue")

        chunkUploadResponseQueue.async {
            var numFileChunks = fileSize / fileChunkSize
            if fileSize % fileChunkSize != 0 {
                numFileChunks += 1
            }
            var totalBytesSent: UInt64 = 0
            let chunkUploadFinished = DispatchSemaphore(value: 0)
            // iterate through all remaining chunks and upload each one sequentially
            for i in 1 ..< numFileChunks {
                guard !uploadData.cancel else { break }
                let startBytes = fileChunkSize * i
                let endBytes = (i != numFileChunks - 1) ? fileChunkSize * (i + 1) : fileSize
                let fileChunkInputStream = ChunkInputStream(fileUrl: fileUrlPair.copiedUrl, startBytes: Int(startBytes), endBytes: Int(endBytes))
                totalBytesSent += fileChunkSize
                let cursor = Files.UploadSessionCursor(sessionId: sessionId, offset: totalBytesSent)
                let shouldClose = (i != numFileChunks - 1) ? false : true
                self.appendFileChunk(
                    uploadData: uploadData,
                    fileUrlPair: fileUrlPair,
                    cursor: cursor,
                    shouldClose: shouldClose,
                    fileChunkInputStream: fileChunkInputStream,
                    chunkUploadResponseQueue: chunkUploadResponseQueue,
                    chunkUploadFinished: chunkUploadFinished,
                    retryCount: 0,
                    startBytes: startBytes,
                    endBytes: endBytes
                )
                // wait until each chunk upload completes before resuming loop iteration
                _ = chunkUploadFinished.wait(timeout: DispatchTime.now() + .seconds(480))
                guard uploadData.fileUrlPairsToRequestErrors[fileUrlPair] == nil else { break }
            }
            uploadData.uploadGroup.leave()
        }
    }

    func appendFileChunk(
        uploadData: BatchUploadData,
        fileUrlPair: BatchUploadData.UrlPair,
        cursor: Files.UploadSessionCursor,
        shouldClose: Bool,
        fileChunkInputStream: ChunkInputStream,
        chunkUploadResponseQueue: DispatchQueue,
        chunkUploadFinished: DispatchSemaphore,
        retryCount: Int,
        startBytes: UInt64,
        endBytes: UInt64
    ) {
        // close session on final append call

        let request = uploadSessionAppendV2(cursor: cursor, close: shouldClose, input: fileChunkInputStream).response(
            queue: DispatchQueue(label: "chunk_append_response_queue"),
            completionHandler: { result, error in
                uploadData.appendRequests[fileUrlPair] = nil
                if result == nil {
                    if let error = error {
                        switch error as CallError {
                        case .rateLimitError(let rateLimitError, _, _, _):
                            let backoffInSeconds = rateLimitError.retryAfter
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(backoffInSeconds)) {
                                if retryCount <= 3 {
                                    self.appendFileChunk(
                                        uploadData: uploadData,
                                        fileUrlPair: fileUrlPair,
                                        cursor: cursor,
                                        shouldClose: shouldClose,
                                        fileChunkInputStream: fileChunkInputStream,
                                        chunkUploadResponseQueue: chunkUploadResponseQueue,
                                        chunkUploadFinished: chunkUploadFinished,
                                        retryCount: retryCount + 1,
                                        startBytes: startBytes,
                                        endBytes: endBytes
                                    )
                                } else {
                                    uploadData.fileUrlPairsToRequestErrors[fileUrlPair] = .appendError(error)
                                }
                            }
                        default:
                            uploadData.fileUrlPairsToRequestErrors[fileUrlPair] = .appendError(error)
                        }
                    }
                }
                chunkUploadFinished.signal()
            }
        ).progress { progress in
            if retryCount == 0 {
                progress.totalUnitCount = Int64(endBytes - startBytes)
                self.executeProgressHandler(uploadData: uploadData, progress: progress)
            }
        }

        uploadData.appendRequests[fileUrlPair] = request
    }

    func finishBatch(
        uploadData: BatchUploadData,
        entries: [Files.UploadSessionFinishBatchResultEntry]
    ) {
        uploadData.queue.async {
            var dropboxFilePathToNSURL = [String: URL]()
            for (fileUrl, commitInfo) in uploadData.fileUrlPairsToCommitInfo {
                dropboxFilePathToNSURL[commitInfo.path] = fileUrl.callerUrl
            }
            var fileUrlsToBatchResultEntries: [URL: Files.UploadSessionFinishBatchResultEntry] = [:]
            var index = 0
            for finishArg in uploadData.finishArgs {
                let path = finishArg.commit.path
                guard let dropboxFilePathToNSURL = dropboxFilePathToNSURL[path] else { continue }
                let resultEntry: Files.UploadSessionFinishBatchResultEntry? = entries[index]
                fileUrlsToBatchResultEntries[dropboxFilePathToNSURL] = resultEntry
                index += 1
            }
            uploadData.responseBlock(fileUrlsToBatchResultEntries, nil, self.fileUrlsToRequestErrors(from: uploadData))
            self.cleanUpTempDirectory(tempDirectory: uploadData.tempDirectoryUrl)
        }
    }

    func batchFinishUponCompletion(uploadData: BatchUploadData) {
        uploadData.uploadGroup.notify(queue: DispatchQueue.main) {
            uploadData.finishArgs.sort { $0.commit.path < $1.commit.path }

            let request = self.uploadSessionFinishBatchV2(entries: uploadData.finishArgs).response { result, error in
                if let result = result {
                    self.finishBatch(uploadData: uploadData, entries: result.entries)
                } else {
                    uploadData.queue.async {
                        let batchError: BatchUploadError? = error.map { .finishError($0) }
                        uploadData.responseBlock(nil, batchError, self.fileUrlsToRequestErrors(from: uploadData))
                        self.cleanUpTempDirectory(tempDirectory: uploadData.tempDirectoryUrl)
                    }
                }
                uploadData.finishRequest = nil
            }

            uploadData.finishRequest = request
        }
    }

    func executeProgressHandler(uploadData: BatchUploadData, progress: Progress) {
        if let progressBlock = uploadData.progressBlock, let totalUploadProgress = uploadData.totalUploadProgress {
            uploadData.queue.async {
                // Only increment total progress if one of the requests is completed
                if progress.totalUnitCount == progress.completedUnitCount {
                    totalUploadProgress.completedUnitCount += progress.completedUnitCount
                }
                progressBlock(totalUploadProgress)
            }
        }
    }

    func fileUrlsToRequestErrors(from uploadData: BatchUploadData) -> [URL: BatchUploadError] {
        uploadData.fileUrlPairsToRequestErrors.reduce([:]) { partialResult, keyValuePair in
            var dict = partialResult
            dict[keyValuePair.key.callerUrl] = keyValuePair.value
            return dict
        }
    }

    // Copying URLs for upload

    var fileManager: FileManager {
        FileManager.default
    }

    func copyUrlsToTempDirectory(tempDirectory: URL, fileUrlsToCommitInfo: [URL: Files.CommitInfo]) throws -> [BatchUploadData.UrlPair: Files.CommitInfo] {
        var copiedPairs: [BatchUploadData.UrlPair: Files.CommitInfo] = [:]

        // Create temporary directory if it does not exist
        if !fileManager.fileExists(atPath: tempDirectory.path) {
            try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        // Copy each file URL to the temporary directory
        for (fileUrl, commitInto) in fileUrlsToCommitInfo {
            let copiedFileUrl = tempDirectory.appendingPathComponent(UUID().uuidString)

            try fileManager.copyItem(at: fileUrl, to: copiedFileUrl)

            let urlPair = BatchUploadData.UrlPair(callerUrl: fileUrl, copiedUrl: copiedFileUrl)
            copiedPairs[urlPair] = commitInto
        }

        return copiedPairs
    }

    func cleanUpTempDirectory(tempDirectory: URL) {
        do {
            try fileManager.removeItem(at: tempDirectory)
        } catch {
            DropboxClientsManager.log(.error, "Error deleting batch upload temp directory: \(error.localizedDescription)")
        }
    }
}
