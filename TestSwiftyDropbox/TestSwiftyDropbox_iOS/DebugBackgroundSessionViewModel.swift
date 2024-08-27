//
//  Copyright © 2023 Dropbox. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftyDropbox

@available(iOS 16.0, *)
class DebugBackgroundSessionViewModel: ObservableObject {
    @Published var numberOfDownloads: Int = 0
    @Published var numberOfUploads: Int = 0
    @Published var sizeOfUpload: String = ""
    @Published var exitOnBackgrounding: Bool = false
    @Published var showFileBrowser = false
    @Published var showLogBrowser = false

    func startDownloads() {
        for i in 0 ..< numberOfDownloads {
            let path = TestConstants.dropboxTestFolder + "/test_\(i).txt"
            let destinationURL = TestConstants.localDownloadFolder
                .appending(component: "test_\(i).txt")

            DropboxClientsManager.authorizedBackgroundClient?.files.download(path: path, destination: destinationURL).response { result, error in
                let metadata = result?.0
                DropboxClientsManager.logBackgroundSession(DebugBackgroundSessionHelpers.summary(of: "download", from: metadata, error: error))
            }
        }
    }

    func startUploads() {
        TestUtilities.createFileToUpload(sizeInKBs: Double(sizeOfUpload) ?? 1)

        for i in 0 ..< numberOfUploads {
            let path = TestConstants.dropboxTestFolder + "/test_\(i).txt"
            Self.upload(path: path, input: TestConstants.fileToUpload)
        }
    }

    static let separator = "###___###"

    static func upload(path: String, input: URL, after: Double? = nil) {
        let work: () -> Void = {
            DropboxClientsManager.authorizedBackgroundClient?.files.upload(path: path, input: input)
                .persistingString(string: path + Self.separator + input.path)
                .response { response, error in
                    DropboxClientsManager.logBackgroundSession(DebugBackgroundSessionHelpers.summary(of: "upload", from: response, error: error))

                    if case .rateLimitError(let limitError, _, _, _) = error {
                        self.upload(path: path, input: input, after: Double(limitError.retryAfter))
                    }
                }
        }

        if let after = after {
            DispatchQueue.main.asyncAfter(deadline: .now() + after) {
                work()
            }
        } else {
            work()
        }
    }

    func deleteDropboxTestFolder() {
        DropboxClientsManager.authorizedClient?.files.deleteV2(path: TestConstants.dropboxTestFolder)
            .response { response, error in
                DropboxClientsManager.logBackgroundSession(DebugBackgroundSessionHelpers.summary(of: "deleteV2", from: response, error: error))
            }
    }

    func createDropboxTestFolder() {
        DropboxClientsManager.authorizedClient?.files.createFolderV2(path: TestConstants.dropboxTestFolder)
            .response { response, error in
                DropboxClientsManager.logBackgroundSession(DebugBackgroundSessionHelpers.summary(of: "createFolderV2", from: response, error: error))
            }
    }

    func deleteLocalDownloads() {
        do {
            DropboxClientsManager.logBackgroundSession("deleteLocalDownloadsFolder at \(TestConstants.localDownloadFolder)")
            try FileManager.default.removeItem(at: TestConstants.localDownloadFolder)
        } catch {
            print("Error deleting folder: \(error)")
        }
    }

    func createLocalDownloadsFolder() {
        do {
            DropboxClientsManager.logBackgroundSession("createLocalDownloadsFolder at \(TestConstants.localDownloadFolder)")
            try FileManager.default.createDirectory(at: TestConstants.localDownloadFolder, withIntermediateDirectories: true)
        } catch {
            print("Error creating folder: \(error)")
        }
    }

    static func processReconnect(requestResults: [Result<DropboxBaseRequestBox, ReconnectionError>]) {
        let successfulReturnedRequests = requestResults.compactMap { result -> DropboxBaseRequestBox? in
            switch result {
            case .success(let requestBox):
                return requestBox
            case .failure(let error):
                DropboxClientsManager.logBackgroundSession("attemptReconnect error: \(error)")
                return nil
            }
        }
        DropboxClientsManager.logBackgroundSession("attemptReconnect returned requests \(requestResults)")
        DropboxClientsManager.logBackgroundSession("attemptReconnect successful returned requests \(successfulReturnedRequests)")

        for request in successfulReturnedRequests {
            switch request {
            case .files_download(let downloadRequest):
                downloadRequest.response { response, error in
                    if let result = response {
                        let writtenContent = String(data: FileManager.default.contents(atPath: result.1.path()) ?? .init(), encoding: .utf8)
                        DropboxClientsManager.logBackgroundSession("attemptReconnect download complete with content: \(writtenContent ?? "none")")
                    } else if let callError = error {
                        DropboxClientsManager.logBackgroundSession("attemptReconnect download errored: \(callError)")
                    }
                }
            case .files_upload(let uploadRequest):
                uploadRequest.response { response, error in
                    if let result = response {
                        DropboxClientsManager.logBackgroundSession("attemptReconnect upload complete with size: \(result.size)")
                    } else if let callError = error {
                        if case .rateLimitError(let limitError, _, _, _) = error {
                            DropboxClientsManager.logBackgroundSession(DebugBackgroundSessionHelpers.summary(of: "upload", from: response, error: error))
                            let persistedString = uploadRequest.clientPersistedString ?? ""
                            let components = persistedString.components(separatedBy: Self.separator)
                            let (dbPath, input) = (components[0], components[1])

                            let url = URL(fileURLWithPath: input)
                            DropboxClientsManager.logBackgroundSession("attemptReconnect upload rate limited: \(dbPath) \(url)")
                            DropboxClientsManager.logBackgroundSession("attemptReconnect upload rate limited retry")

                            self.upload(path: dbPath, input: url, after: Double(limitError.retryAfter))
                        } else {
                            DropboxClientsManager.logBackgroundSession("attemptReconnect upload errored: \(callError)")
                        }
                    }
                }
            default:
                DropboxClientsManager.logBackgroundSession("attemptReconnect unexpected reconnected type: \(request)")
            }
        }
    }
}

enum DebugBackgroundSessionHelpers {
    static func summary(of route: String, from response: CustomStringConvertible?, error: CustomStringConvertible?) -> String {
        "\(route) response: \(response?.description ?? "nil") error: \(error?.description ?? "nil")"
    }
}
