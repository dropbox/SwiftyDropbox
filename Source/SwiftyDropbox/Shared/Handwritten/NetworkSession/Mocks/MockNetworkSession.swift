//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

class MockNetworkSession: NetworkSession {
    var identifier: String?

    init() {}

    required init(configuration: URLSessionConfiguration) {
        fatalError()
    }

    var tasksPendingReconnection: [NetworkTask] = []
    var tasks: [NetworkTaskTag: NetworkTask] = [:]
    var mockInputs: [NetworkTaskTag: MockInput] = [:]

    var invalidateCalled = false

    func dataTask(request: URLRequest, networkTaskTag: NetworkTaskTag?) -> NetworkDataTask {
        register(
            task: MockNetworkTaskDelegate(request: request),
            networkTaskTag: networkTaskTag
        )
    }

    func dataTask(request: URLRequest, networkTaskTag: NetworkTaskTag?, completionHandler: @escaping NetworkDataTaskCompletion) -> NetworkDataTask {
        register(
            task: MockNetworkDataTaskCompletion(
                request: request,
                mockInput: { [weak self] in
                    networkTaskTag.flatMap { self?.mockInputs[$0] }
                },
                completionHandler: completionHandler
            ),
            networkTaskTag: networkTaskTag
        )
    }

    func uploadTaskData(request: URLRequest, data: Data, networkTaskTag: NetworkTaskTag?) -> NetworkUploadTask {
        register(
            task: MockNetworkTaskDelegate(request: request),
            networkTaskTag: networkTaskTag
        )
    }

    func uploadTaskStream(request: URLRequest, networkTaskTag: NetworkTaskTag?) -> NetworkUploadTask {
        register(
            task: MockNetworkTaskDelegate(request: request),
            networkTaskTag: networkTaskTag
        )
    }

    func uploadTaskFile(request: URLRequest, file: URL, networkTaskTag: NetworkTaskTag?) -> NetworkUploadTask {
        register(
            task: MockNetworkTaskDelegate(request: request),
            networkTaskTag: networkTaskTag
        )
    }

    func downloadTask(request: URLRequest, networkTaskTag: NetworkTaskTag?) -> NetworkDownloadTask {
        register(
            task: MockNetworkTaskDelegate(request: request),
            networkTaskTag: networkTaskTag
        )
    }

    func register<T: NetworkTask>(task: T, networkTaskTag: NetworkTaskTag?) -> T {
        tasks[networkTaskTag ?? UUID().uuidString] = task
        return task
    }

    func getAllNetworkTasks(completionHandler: ([NetworkTask]) -> Void) {
        completionHandler(tasksPendingReconnection)
    }

    func invalidateAndCancel() {
        invalidateCalled = true
    }
}

enum MockInput {
    case none
    case success(json: [String: Any])
    case downloadSuccess(json: [String: Any], downloadLocation: URL)
    case requestError(json: [String: Any], code: NetworkStatusCode)
    case routeError(json: [String: Any])
    case clientError(error: ClientError)
}

enum MockInputWithModel {
    case none
    case success(model: JSONRepresentable)
    case downloadSuccess(model: JSONRepresentable, downloadLocation: URL)
    case requestError(model: JSONRepresentable, code: NetworkStatusCode)
    case routeError(model: JSONRepresentable)
}
