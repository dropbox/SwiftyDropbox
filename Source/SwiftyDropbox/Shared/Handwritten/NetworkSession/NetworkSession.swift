//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

protocol NetworkSession: AnyObject {
    var identifier: String? { get }

    init(configuration: URLSessionConfiguration)

    func dataTask(request: URLRequest, networkTaskTag: NetworkTaskTag?) -> NetworkDataTask
    func dataTask(request: URLRequest, networkTaskTag: NetworkTaskTag?, completionHandler: @escaping NetworkDataTaskCompletion) -> NetworkDataTask

    func uploadTaskData(request: URLRequest, data: Data, networkTaskTag: NetworkTaskTag?) -> NetworkUploadTask
    func uploadTaskStream(request: URLRequest, networkTaskTag: NetworkTaskTag?) -> NetworkUploadTask
    func uploadTaskFile(request: URLRequest, file: URL, networkTaskTag: NetworkTaskTag?) -> NetworkUploadTask

    func downloadTask(request: URLRequest, networkTaskTag: NetworkTaskTag?) -> NetworkDownloadTask

    func getAllNetworkTasks(completionHandler: @escaping ([NetworkTask]) -> Void)

    func invalidateAndCancel()
}

typealias CombinedURLSessionDelegate = URLSessionDataDelegate & URLSessionDownloadDelegate

protocol NetworkSessionDelegate {
    func networkSession(_ session: NetworkSession, dataTask: NetworkDataTask, didReceive data: Data)

    func networkSession(_ session: NetworkSession, task: NetworkTask, didCompleteWithError error: Error?)
    func networkSession(
        _ session: NetworkSession,
        downloadTask: NetworkDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    )
    func networkSession(_ session: NetworkSession, downloadTask: NetworkDownloadTask, didFinishDownloadingTo location: URL)

    func networkSession(_ session: NetworkSession, task: NetworkTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)

    func networkSession(
        _ session: NetworkSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )

    func networkSessionDidFinishEvents(forBackgroundNetworkSession session: NetworkSession)
}

extension URLSession: NetworkSession {
    var identifier: String? {
        configuration.identifier
    }

    func dataTask(request: URLRequest, networkTaskTag: NetworkTaskTag?, completionHandler: @escaping NetworkDataTaskCompletion) -> NetworkDataTask {
        dataTask(with: request) { data, response, error in
            completionHandler(.init(data: data, response: response, error: error.map { .urlSessionError($0) }))
        }
    }

    func dataTask(request: URLRequest, networkTaskTag: NetworkTaskTag?) -> NetworkDataTask {
        dataTask(with: request)
    }

    func uploadTaskData(request: URLRequest, data: Data, networkTaskTag: NetworkTaskTag?) -> NetworkUploadTask {
        uploadTask(with: request, from: data)
    }

    func uploadTaskStream(request: URLRequest, networkTaskTag: NetworkTaskTag?) -> NetworkUploadTask {
        uploadTask(withStreamedRequest: request)
    }

    func uploadTaskFile(request: URLRequest, file: URL, networkTaskTag: NetworkTaskTag?) -> NetworkUploadTask {
        uploadTask(with: request, fromFile: file)
    }

    func downloadTask(request: URLRequest, networkTaskTag: NetworkTaskTag?) -> NetworkDownloadTask {
        downloadTask(with: request)
    }

    func getAllNetworkTasks(completionHandler: @escaping (([NetworkTask]) -> Void)) {
        getAllTasks { urlSessionTasks in
            let tasks: [URLSessionTask] = urlSessionTasks
            completionHandler(tasks)
        }
    }
}
