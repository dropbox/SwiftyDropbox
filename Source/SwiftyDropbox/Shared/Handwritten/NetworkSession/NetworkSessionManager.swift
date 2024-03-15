//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

typealias NetworkTaskCreation = () -> NetworkTask
typealias OnTaskCreation = (ApiRequest) -> Void
typealias ApiRequestCreation = (@escaping NetworkTaskCreation, @escaping OnTaskCreation) -> ApiRequest

@objc(DBNetworkSessionManager)
class NetworkSessionManager: NSObject {
    let session: NetworkSession
    let requestMap: RequestMap
    var didFinishBackgroundEvents: (() -> Void)?

    var apiRequestCreation: ApiRequestCreation?
    var apiRequestReconnectionCreation: ((NetworkTask) -> ApiRequest)?

    private let authChallengeHandler: AuthChallenge.Handler?
    private var isShutdown: Bool = false

    var isBackgroundManager: Bool {
        session.identifier != nil
    }

    var identifier: String? {
        session.identifier
    }

    let delegateQueue: OperationQueue = {
        let instance = OperationQueue()
        instance.maxConcurrentOperationCount = 1
        return instance
    }()

    private let isolationQueue: DispatchQueue = DispatchQueue(label: "NetworkSessionManagerQueue")

    private let passthroughDelegate: NetworkSessionPassthroughDelegate = .init()

    init(
        sessionCreation: (CombinedURLSessionDelegate, OperationQueue) -> NetworkSession,
        apiRequestReconnectionCreation: ((NetworkTask) -> ApiRequest)?,
        requestMap: RequestMap = RequestMapImpl(),
        authChallengeHandler: AuthChallenge.Handler?
    ) {
        self.session = sessionCreation(passthroughDelegate, delegateQueue)
        self.requestMap = requestMap
        self.apiRequestReconnectionCreation = apiRequestReconnectionCreation
        self.authChallengeHandler = authChallengeHandler

        super.init()

        passthroughDelegate.delegate = self
    }

    func getAllTasks(completionHandler: @escaping ([ApiRequest]) -> Void) {
        session.getAllNetworkTasks { [weak self] networkTasks in
            self?.isolationQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                DropboxClientsManager.logBackgroundSession("getAllTasks from URLSession returned \(networkTasks.count) \(networkTasks)")

                // All ongoing URLSessionTasks that the request map knows of
                let existingRequestMapApiRequests = self.requestMap.getAllRequests()
                let existingRequestMapTaskIdentifiers = existingRequestMapApiRequests.map(\.identifier)

                // All ongoing unowned URLSessionTasks that the request map knows of
                let unownedRequestMapApiRequests = self.requestMap.getAllPendingReconnectionRequests()

                DropboxClientsManager
                    .logBackgroundSession(
                        "getAllTasks existingUnownedApiRequests in request map \(unownedRequestMapApiRequests.count) \(unownedRequestMapApiRequests)"
                    )

                let untrackedApiRequestsFromClosure: [ApiRequest] = networkTasks.compactMap {
                    let isTracked = existingRequestMapTaskIdentifiers.contains($0.taskIdentifier)

                    if isTracked {
                        // URLSessionDelegate learned of the task before getAllNetworkTasks.
                        // It is either an unowned request already rewrapped or an owned request.
                        // Neither need wrapping or registering.
                        return nil
                    } else {
                        // getAllNetworkTasks learned of the task before URLSessionDelegate.
                        // Include it here for rewrapping.
                        return self.registeredPendingReconnectionApiRequest(from: $0)
                    }
                }

                // Note that we're only reconnecting unowned `ApiRequests` (those not retained by a `Request`)
                // Owned `ApiRequests` could exist in the request map at the point if the app was backgrounded but not terminated,
                // or if additional requests were created after the app was relaunched.
                // For these, no reconnection is needed, the `Request` is in memory and already has a completion block if previously set.
                let apiRequestsToReconnect = unownedRequestMapApiRequests + untrackedApiRequestsFromClosure

                // Guard against reentrancy issues by dispatching the completion async to main
                DispatchQueue.main.async {
                    completionHandler(
                        apiRequestsToReconnect
                    )
                }

                // API requests are typically retained by a Request<ESerial, RSerial>
                // In the reconnection case, these requests don't yet exist so the request map retains them instead
                // Once they've been vended for reconnection to a Request<ESerial, RSerial>, weakify them in the request map
                self.requestMap.weakifyReferencesToReconnectedRequests()
            }
        }
    }

    public func shutdown() {
        isolationQueue.sync {
            self.isShutdown = true
            self.session.invalidateAndCancel()
        }
    }

    var __testing_only_urlSession: URLSession? {
        session as? URLSession
    }
}

extension NetworkSessionManager {
    func apiRequestData(request: @escaping () -> URLRequest, networkTaskTag: NetworkTaskTag? = nil) -> ApiRequest {
        registeredApiRequest {
            self.session.dataTask(request: request(), networkTaskTag: networkTaskTag)
        }
    }

    func apiRequestUpload(request: @escaping () -> URLRequest, input: UploadBody, networkTaskTag: NetworkTaskTag? = nil) -> ApiRequest {
        registeredApiRequest {
            var task: NetworkTask

            switch input {
            case let .data(data):
                task = self.session.uploadTaskData(request: request(), data: data, networkTaskTag: networkTaskTag)
            case let .file(file):
                task = self.session.uploadTaskFile(request: request(), file: file, networkTaskTag: networkTaskTag)
            case .stream:
                task = self.session.uploadTaskStream(request: request(), networkTaskTag: networkTaskTag)
            }

            return task
        }
    }

    func apiRequestDownloadFile(request: @escaping () -> URLRequest, networkTaskTag: NetworkTaskTag? = nil) -> ApiRequest {
        registeredApiRequest {
            self.session.downloadTask(request: request(), networkTaskTag: networkTaskTag)
        }
    }

    private func registeredApiRequest(from taskCreation: @escaping () -> NetworkTask) -> ApiRequest {
        isolationQueue.sync {
            if self.isShutdown {
                return NoopApiRequest()
            }

            let onTaskCreation = { [weak self] apiRequest in
                guard let self = self else {
                    return
                }

                self.isolationQueue.sync {
                    self.requestMap.set(request: apiRequest, taskIdentifier: apiRequest.identifier)
                }
            }

            guard let apiRequest = apiRequestCreation?(taskCreation, onTaskCreation) else {
                fatalError(
                    "ApiRequestCreation missing: You must set the `apiRequestCreation` block on a NetworkSessionManager before attempting to make requests"
                )
            }

            return apiRequest
        }
    }

    // TODO: programatically enforce isolated access to mutable state
    // Only call on isolation queue
    private func registeredPendingReconnectionApiRequest(from task: NetworkTask) -> ApiRequest? {
        if let apiRequestReconnectionCreation = apiRequestReconnectionCreation {
            let apiRequest = apiRequestReconnectionCreation(task)
            requestMap.setPendingReconnection(request: apiRequest, taskIdentifier: apiRequest.identifier)
            return apiRequest
        }
        return nil
    }
}

extension NetworkSessionManager: NetworkSessionDelegate {
    func networkSession(_ session: NetworkSession, dataTask: NetworkDataTask, didReceive data: Data) {
        executeWorkOnTask(networkTask: dataTask, async: true) { task in
            task.handleRecieve(data: data)
        }
    }

    func networkSession(_ session: NetworkSession, task: NetworkTask, didCompleteWithError error: Error?) {
        executeWorkOnTask(networkTask: task, async: true) { task in
            task.handleCompletion(error: error.flatMap { .urlSessionError($0) })
        }
    }

    func networkSession(
        _ session: NetworkSession,
        downloadTask: NetworkDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        executeWorkOnTask(networkTask: downloadTask, async: true) { task in
            task.handleWroteDownloadData(totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        }
    }

    func networkSession(_ session: NetworkSession, downloadTask: NetworkDownloadTask, didFinishDownloadingTo location: URL) {
        executeWorkOnTask(networkTask: downloadTask, async: false) { task in
            task.handleDownloadFinished(location: location)
        }
    }

    func networkSession(
        _ session: NetworkSession,
        task: NetworkTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        executeWorkOnTask(networkTask: task, async: true) { task in
            task.handleSentBodyData(totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
        }
    }

    func networkSession(
        _ session: NetworkSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if let (disposition, credential) = authChallengeHandler?(challenge) {
            completionHandler(disposition, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    func networkSessionDidFinishEvents(forBackgroundNetworkSession session: NetworkSession) {
        DispatchQueue.main.async {
            self.didFinishBackgroundEvents?()
        }
    }

    private func executeWorkOnTask(networkTask: NetworkTask, async: Bool, work: @escaping (ApiRequest) -> Void) {
        let getRequestAndDoWork: () -> Void = { [weak self] in
            guard let self = self else {
                return
            }

            if let apiRequest = self.requestMap.getRequest(taskIdentifier: networkTask.taskIdentifier) {
                if self.isBackgroundManager {
                    DropboxClientsManager.logBackgroundSession("executeWorkOnTask taskFound \(networkTask.taskIdentifier)")
                }

                work(apiRequest)
            } else {
                if self.isBackgroundManager {
                    DropboxClientsManager.logBackgroundSession("executeWorkOnTask task recreated \(networkTask.taskIdentifier)")

                    guard let registeredPendingReconnectionApiRequest = self.registeredPendingReconnectionApiRequest(from: networkTask) else {
                        DropboxClientsManager.logBackgroundSession(.error, "apiRequestReconnectionCreation missing in background NetworkSessionManager")
                        return
                    }

                    work(
                        registeredPendingReconnectionApiRequest
                    )
                } else {
                    DropboxClientsManager.log(.error, "executeWorkOnTask task not found \(networkTask.taskIdentifier)")
                }
            }
        }

        // work produced by didFinishDownloadingTo must be dispatched sync while the temporary file exists
        if async {
            isolationQueue.async(execute: getRequestAndDoWork)
        } else {
            isolationQueue.sync(execute: getRequestAndDoWork)
        }
    }
}

extension NetworkSessionManager: CombinedURLSessionDelegate {
    @objc
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        DropboxClientsManager.logBackgroundSession("\(#function) \(dataTask.taskIdentifier) bytes: \(data.count)")
        networkSession(session, dataTask: dataTask, didReceive: data)
    }

    @objc
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DropboxClientsManager.logBackgroundSession("\(#function) \(task.taskIdentifier) error: \(error?.localizedDescription ?? "none")")
        networkSession(session, task: task, didCompleteWithError: error)
    }

    @objc
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        DropboxClientsManager
            .logBackgroundSession(
                "\(#function) \(downloadTask.taskIdentifier) bytesWritten: \(bytesWritten), totalBytesWritten: \(totalBytesWritten), totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)"
            )
        networkSession(
            session,
            downloadTask: downloadTask,
            didWriteData: bytesWritten,
            totalBytesWritten: totalBytesWritten,
            totalBytesExpectedToWrite: totalBytesExpectedToWrite
        )
    }

    @objc
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DropboxClientsManager.logBackgroundSession("\(#function) \(downloadTask.taskIdentifier) didFinishDownloadingTolocation: \(location)")
        networkSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }

    @objc
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        DropboxClientsManager
            .logBackgroundSession(
                "\(#function) \(task.taskIdentifier) didSendBodyData: \(bytesSent), totalBytesSent: \(totalBytesSent), totalBytesExpectedToSend: \(totalBytesExpectedToSend)"
            )
        networkSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }

    @objc
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        DropboxClientsManager.logBackgroundSession("\(#function)")
        networkSession(session, didReceive: challenge, completionHandler: completionHandler)
    }

    #if os(iOS)
    @objc
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DropboxClientsManager.logBackgroundSession("\(#function)")
        networkSessionDidFinishEvents(forBackgroundNetworkSession: session)
    }
    #endif
}

// Allows deferring setting a delegate to after session initialization
class NetworkSessionPassthroughDelegate: NSObject, CombinedURLSessionDelegate {
    weak var delegate: CombinedURLSessionDelegate?

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        delegate?.urlSession?(session, dataTask: dataTask, didReceive: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate?.urlSession?(session, task: task, didCompleteWithError: error)
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        delegate?.urlSession?(
            session,
            downloadTask: downloadTask,
            didWriteData: bytesWritten,
            totalBytesWritten: totalBytesWritten,
            totalBytesExpectedToWrite: totalBytesExpectedToWrite
        )
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        delegate?.urlSession?(
            session,
            task: task,
            didSendBodyData: bytesSent,
            totalBytesSent: totalBytesSent,
            totalBytesExpectedToSend: totalBytesExpectedToSend
        )
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        delegate?.urlSession?(session, didReceive: challenge, completionHandler: completionHandler)
    }

    #if os(iOS)
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        delegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
    }
    #endif
}
