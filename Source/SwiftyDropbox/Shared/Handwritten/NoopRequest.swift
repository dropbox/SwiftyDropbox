///
/// Copyright (c) 2023 Dropbox, Inc. All rights reserved.
///

import Foundation

/// Used internally when a URLSessionTask cannot be constructed during shutdown
class NoopApiRequest: ApiRequest {
    init() {}

    func handleCompletion(error: ClientError?) {}

    func handleRecieve(data: Data) {}

    func handleDownloadFinished(location: URL) {}

    func handleSentBodyData(totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {}

    func handleWroteDownloadData(totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {}

    var identifier: Int {
        networkTask?.taskIdentifier ?? -1
    }

    var taskDescription: String?

    var earliestBeginDate: Date?

    func setProgressHandler(_ handler: @escaping (Progress) -> Void) -> Self {
        self
    }

    func setCompletionHandler(queue: DispatchQueue?, completionHandler: RequestCompletionHandler) -> Self {
        self
    }

    func cancel() {}

    func setCleanupHandler(_ handler: @escaping () -> Void) {}

    var networkTask: NetworkTask? = NoopNetworkTask()
}

class NoopNetworkTask: NetworkTask {
    func resume() {}

    func cancel() {}

    var response: URLResponse?

    var error: Error?

    var originalRequest: URLRequest?

    var taskIdentifier: Int = Int.random(in: 1 ..< Int.max)

    var taskDescription: String?

    var earliestBeginDate: Date?
}
