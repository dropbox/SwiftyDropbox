///
/// Copyright (c) 2020 Dropbox, Inc. All rights reserved.
///
import Foundation

typealias WrappedCompletionHandler = () -> Void
typealias DataCompletionHandlerProvider = (NetworkDataTaskResult) -> WrappedCompletionHandler
typealias DownloadCompletionHandlerProvider = (NetworkDownloadTaskResult) -> WrappedCompletionHandler

/// Completion handler for ApiRequest.
enum RequestCompletionHandlerProvider {
    /// Provider of handler for data requests whose results are in memory.
    case dataCompletionHandlerProvider(DataCompletionHandlerProvider)
    /// Provider of handler for download request which stores download result into a file.
    case downloadFileCompletionHandlerProvider(DownloadCompletionHandlerProvider)
}

/// Protocol specifying an entity that can recieve networking info from a NetworkSessionDelegate
protocol NetworkSessionDelegateInfoReceiving {
    func handleCompletion(error: ClientError?)
    func handleRecieve(data: Data)
    func handleDownloadFinished(location: URL)
    func handleSentBodyData(totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    func handleWroteDownloadData(totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
}

/// Protocol defining an API request object.
protocol ApiRequest: NetworkSessionDelegateInfoReceiving, RequestControlling, AnyObject {}

/// Protocol defining an object that controls a network request
protocol RequestControlling {
    /// A unique idenfier for the request
    var identifier: Int { get }

    /// A string persisted on the underlying task across sessions
    var taskDescription: String? { get set }

    /// The earliest date the underlying task will begin
    @available(iOS 13.0, macOS 10.13, *)
    var earliestBeginDate: Date? { get set }

    /// Sets progress handler for the request.
    ///
    /// - Parameter handler: The progress handler.
    ///
    /// Progress handler should always be called back on the main queue.
    @discardableResult
    func setProgressHandler(_ handler: @escaping (Progress) -> Void) -> Self

    /// Sets a completion handler for the request.
    ///
    /// - Parameters:
    ///     - completionHandlerProvider The completion handler provider.
    ///     - queue: The queue where the provided completion handler will be called from.
    @discardableResult
    func setCompletionHandlerProvider(queue: DispatchQueue?, completionHandlerProvider: RequestCompletionHandlerProvider) -> Self

    /// Cancels the request.
    func cancel()

    /// Set a block that can be called when the request completes or cancels.
    func setCleanupHandler(_ handler: @escaping () -> Void)

    /// The underlying network task
    var networkTask: NetworkTask? { get }
}

/// A class that wraps a network request that calls Dropbox API.
/// This class will first attempt to refresh the access token and conditionally proceed to the actual API call.
class RequestWithTokenRefresh: ApiRequest {
    class StateAccess {
        private var mutableState: MutableState
        private var lock = { // heap allocate the lock for use in Swift
            let lock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
            lock.initialize(to: .init())
            return lock
        }()

        init(mutableState: MutableState) {
            self.mutableState = mutableState
        }

        deinit {
            lock.deinitialize(count: 1)
            lock.deallocate()
        }

        fileprivate func accessStateWithLock<T>(block: (MutableState) throws -> T) rethrows -> T {
            os_unfair_lock_lock(lock)
            defer { os_unfair_lock_unlock(lock) }
            return try block(mutableState)
        }
    }

    class MutableState {
        init() {}

        // MARK: NetworkSessionDelegateInfoReceiving support

        var data: Data = .init()
        var progress: Progress?
        var temporaryDownloadURL: URL?
        var moveDownloadError: Error?

        var response: HTTPURLResponse? {
            request?.response as? HTTPURLResponse
        }

        var taskIdentifier: Int {
            request?.taskIdentifier ?? -1
        }

        var taskDescription: String? {
            get {
                if let request = request {
                    return request.taskDescription
                } else {
                    return preRequestTaskDescription
                }
            }
            set {
                if let request = request {
                    request.taskDescription = newValue
                } else {
                    preRequestTaskDescription = newValue
                }
            }
        }

        var preRequestTaskDescription: String?
        var preRequestEarliestBeginDate: Date?

        @available(iOS 13.0, macOS 10.13, *)
        var earliestBeginDate: Date? {
            get {
                if let request = request {
                    return request.earliestBeginDate
                } else {
                    return preRequestEarliestBeginDate
                }
            }
            set {
                if let request = request {
                    request.earliestBeginDate = newValue
                } else {
                    preRequestEarliestBeginDate = newValue
                }
            }
        }

        // MARK: RequestControlling support

        fileprivate var request: NetworkTask?
        fileprivate var cancelled = false
        fileprivate var isComplete = false
        fileprivate var responseQueue: DispatchQueue?
        fileprivate var completionHandlerProvider: RequestCompletionHandlerProvider?
        fileprivate var progressHandler: ((Progress) -> Void)?
        fileprivate var cleanupHandler: (() -> Void)?

        fileprivate var completionHandlerQueue: DispatchQueue {
            responseQueue ?? DispatchQueue.main
        }

        func handleRequestCreation() {
            request?.taskDescription = preRequestTaskDescription
            if #available(iOS 13.0, *) {
                request?.earliestBeginDate = preRequestEarliestBeginDate
            }
            preRequestTaskDescription = nil
            preRequestEarliestBeginDate = nil

            __test_only_onRequestCreation?()
        }

        // MARK: test helpers

        func __test_only_setOnRequestCreation(block: @escaping () -> Void) {
            if request != nil {
                block()
            } else {
                __test_only_onRequestCreation = block
            }
        }

        var __test_only_onRequestCreation: (() -> Void)?
    }

    private let stateAccess: StateAccess
    private let filesAccess: FilesAccess

    var networkTask: NetworkTask? {
        accessStateWithLock { mutableState in
            mutableState.request
        }
    }

    var identifier: Int {
        accessStateWithLock { mutableState in
            mutableState.taskIdentifier
        }
    }

    var taskDescription: String? {
        get {
            accessStateWithLock { mutableState in
                mutableState.taskDescription
            }
        }
        set {
            accessStateWithLock { mutableState in
                mutableState.taskDescription = newValue
            }
        }
    }

    @available(iOS 13.0, macOS 10.13, *)
    var earliestBeginDate: Date? {
        get {
            accessStateWithLock { mutableState in
                mutableState.earliestBeginDate
            }
        }
        set {
            accessStateWithLock { mutableState in
                mutableState.earliestBeginDate = newValue
            }
        }
    }

    /// Designated Initializer.
    ///
    /// - Parameters:
    ///     - request: The actual API request.
    ///     - onTaskCreation: A block to be executed after token refresh and network task creation.
    ///     - tokenProvider: The `AccessTokenProvider` to perform token refresh.
    ///     - filesAccess: The implementation that reads and moves files on disk.
    init(requestCreation: @escaping NetworkTaskCreation, onTaskCreation: @escaping OnTaskCreation, authStrategy: AuthStrategy, filesAccess: FilesAccess) {
        let mutableState = MutableState()
        self.stateAccess = StateAccess(mutableState: mutableState)
        self.filesAccess = filesAccess

        let setTask = {
            // It is important to run this block, which may do a lot of work outside the SDK,
            // before getting the lock.  We have seen deadlock scenarios like the following:
            // 1. Enter thread safe code behind a lock in your app
            // 2. Start a request from behind that lock in your app
            // 3. We would get the access state lock below before executing requestCreation()
            // 4. This request creation block eventually goes back out to your app's code to get headers
            // 5. Once in your app's code, it needs to go into the code locked in step 1 to get info for headers
            // 6. Deadlock
            //
            // Because we don't have contention between threads to run the requestCreation() block,
            // it can be omitted from the locked section.
            let task = requestCreation()
            self.accessStateWithLock { state in
                state.request = task
                state.handleRequestCreation()
            }
            onTaskCreation(self)
        }

        switch authStrategy {
        case .accessToken(let provider):
            provider.refreshAccessTokenIfNecessary { result in
                DispatchQueue.global(qos: .userInteractive).async {
                    setTask()
                    self.handleTokenRefreshResult(result)
                }
            }
        case .appKeyAndSecret:
            DispatchQueue.global(qos: .userInteractive).async {
                setTask()
                self.handleTokenRefreshResult(nil)
            }
        }
    }

    /// Initializer reconnecting background requests.
    ///
    /// - Parameters:
    ///     - backgroundRequest: The actual API request.
    ///     - filesAccess: The implementation that reads and moves files on disk.
    init(backgroundRequest: NetworkTask, filesAccess: FilesAccess) {
        let mutableState = MutableState()
        self.stateAccess = StateAccess(mutableState: mutableState)
        stateAccess.accessStateWithLock { state in
            state.request = backgroundRequest
        }
        self.filesAccess = filesAccess
    }

    func setCompletionHandlerProvider(queue: DispatchQueue?, completionHandlerProvider: RequestCompletionHandlerProvider) -> Self {
        accessStateWithLock { mutableState in
            mutableState.responseQueue = queue
            if mutableState.isComplete {
                call(completionHandler: completionHandlerProvider, error: mutableState.request?.clientError, mutableState: mutableState)
            } else {
                mutableState.completionHandlerProvider = completionHandlerProvider
            }
        }
        return self
    }

    func setProgressHandler(_ handler: @escaping (Progress) -> Void) -> Self {
        accessStateWithLock { mutableState in
            mutableState.progressHandler = handler
        }
        return self
    }

    func cancel() {
        accessStateWithLock { mutableState in
            mutableState.cancelled = true
            mutableState.request?.cancel()
        }
        cleanup()
    }

    func setCleanupHandler(_ handler: @escaping () -> Void) {
        accessStateWithLock { mutableState in
            mutableState.cleanupHandler = handler
        }
    }

    private func cleanup(mutableState: MutableState? = nil) {
        let cleanup: (MutableState) -> Void = { mutableState in
            mutableState.cleanupHandler?()
            mutableState.cleanupHandler = nil
            mutableState.progressHandler = nil
            mutableState.completionHandlerProvider = nil
        }

        if let mutableState = mutableState {
            cleanup(mutableState)
        } else {
            accessStateWithLock { mutableState in
                cleanup(mutableState)
            }
        }
    }

    private func handleTokenRefreshResult(_ result: DropboxOAuthResult?) {
        if case let .error(oauthError, _) = result, !oauthError.isInvalidGrantError {
            // Refresh failed, due to an error that's not invalid grant, e.g. A refresh request timed out.
            // Complete request with error immediately, so developers could retry and get access token refreshed.
            // Otherwise, the API request may proceed with an expired access token which would lead to
            // a false positive auth error.
            self.completeWithError(.oauthError(oauthError))
        } else {
            // Refresh succeeded or a refresh is not required, i.e. access token is valid, continue request normally.
            // Or
            // Refresh failed due to invalid grant, e.g. refresh token revoked by user.
            // Continue, and the API call would failed with an auth error that developers can handle properly.
            // e.g. Sign out the user upon auth error.
            accessStateWithLock { mutableState in
                if mutableState.cancelled {
                    mutableState.request?.cancel()
                } else {
                    mutableState.request?.resume()
                }
            }
        }
    }

    private func completeWithError(_ error: ClientError) {
        accessStateWithLock { mutableState in
            if let completionHandler = mutableState.completionHandlerProvider {
                call(completionHandler: completionHandler, error: error, mutableState: mutableState)
            }
        }

        cleanup()
    }

    fileprivate func accessStateWithLock<T>(block: (MutableState) throws -> T) rethrows -> T {
        try stateAccess.accessStateWithLock { mutableState in
            try block(mutableState)
        }
    }
}

// MARK: NetworkSessionDelegateInfoReceiving

extension RequestWithTokenRefresh {
    func handleSentBodyData(totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        accessStateWithLock { mutableState in
            handleProgress(mutableState: mutableState, completed: totalBytesSent, total: totalBytesExpectedToSend)
        }
    }

    func handleWroteDownloadData(totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        accessStateWithLock { mutableState in
            handleProgress(mutableState: mutableState, completed: totalBytesWritten, total: totalBytesExpectedToWrite)
        }
    }

    private func handleProgress(mutableState: MutableState, completed: Int64, total: Int64) {
        if mutableState.progress == nil {
            mutableState.progress = Progress(totalUnitCount: total)
        }
        guard let progress = mutableState.progress else {
            return
        }

        progress.completedUnitCount = completed

        if let progressHandler = mutableState.progressHandler {
            mutableState.completionHandlerQueue.async {
                progressHandler(progress)
            }
        }
    }

    func handleDownloadFinished(location: URL) {
        accessStateWithLock { mutableState in
            do {
                mutableState.temporaryDownloadURL = try filesAccess.moveFileToTemporaryLocation(from: location)
                let logInfo = "\(mutableState.taskIdentifier) \(mutableState.temporaryDownloadURL?.absoluteString ?? "none")"
                DropboxClientsManager.logBackgroundSession("handleDownloadFinished successful move \(logInfo)")
            } catch {
                DropboxClientsManager.logBackgroundSession("handleDownloadFinished move error \(mutableState.taskIdentifier) \(error)")
                mutableState.moveDownloadError = error
            }
        }
    }

    func handleCompletion(error: ClientError?) {
        accessStateWithLock { mutableState in
            mutableState.isComplete = true

            if let completionHandler = mutableState.completionHandlerProvider {
                DropboxClientsManager.logBackgroundSession("handleCompletion called with handler \(mutableState.taskIdentifier)")
                call(completionHandler: completionHandler, error: error, mutableState: mutableState)
            } else {
                // no-op: wait for completion handler to be set
                DropboxClientsManager.logBackgroundSession("handleCompletion called pending handler \(mutableState.taskIdentifier)")
            }
        }
    }

    private func call(completionHandler completionHanderProvider: RequestCompletionHandlerProvider, error: ClientError?, mutableState: MutableState) {
        switch completionHanderProvider {
        case .dataCompletionHandlerProvider(let handlerProvider):
            callDataCompletionHandler(error: error, mutableState: mutableState, handlerProvider: handlerProvider)
        case .downloadFileCompletionHandlerProvider(let handlerProvider):
            callDownloadCompletionHandler(error: error, mutableState: mutableState, handlerProvider: handlerProvider)
        }
    }

    private func callDataCompletionHandler(
        error: ClientError?,
        mutableState: MutableState,
        handlerProvider: @escaping ((NetworkDataTaskResult) -> WrappedCompletionHandler)
    ) {
        // copy for use out of lock
        let data = mutableState.data
        let response = mutableState.response
        let completionQueue = mutableState.completionHandlerQueue

        // lock is held above this line but not below, do not again reference mutableState

        if DropboxTransportClientImpl.serializeOnBackgroundThread {
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = handlerProvider(.init(
                    data: data,
                    response: response,
                    error: error
                ))

                completionQueue.async {
                    handler()
                    self.cleanup()
                }
            }
        } else {
            completionQueue.async {
                let handler = handlerProvider(.init(
                    data: data,
                    response: response,
                    error: error
                ))
                handler()
                self.cleanup()
            }
        }
    }

    private func callDownloadCompletionHandler(
        error: ClientError?,
        mutableState: MutableState,
        handlerProvider: @escaping ((NetworkDownloadTaskResult) -> WrappedCompletionHandler)
    ) {
        // copy for use out of lock
        let temporaryDownloadURL = mutableState.temporaryDownloadURL
        let response = mutableState.response
        let moveDownloadError: ClientError? = mutableState.moveDownloadError.map { .fileAccessError($0) }
        let completionQueue = mutableState.completionHandlerQueue

        // lock is held above this line but not below, do not again reference mutableState

        if DropboxTransportClientImpl.serializeOnBackgroundThread {
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = handlerProvider(.init(
                    url: temporaryDownloadURL,
                    response: response,
                    error: error ?? moveDownloadError,
                    errorDataFromLocation: self.filesAccess.errorData(from:)
                ))

                completionQueue.async {
                    handler()
                    self.cleanup()
                }
            }
        } else {
            completionQueue.async {
                let handler = handlerProvider(.init(
                    url: temporaryDownloadURL,
                    response: response,
                    error: error ?? moveDownloadError,
                    errorDataFromLocation: self.filesAccess.errorData(from:)
                ))
                handler()
                self.cleanup()
            }
        }
    }

    func handleRecieve(data: Data) {
        accessStateWithLock { mutableState in
            mutableState.data.append(data)
        }
    }
}

// MARK: Test support

extension RequestWithTokenRefresh {
    var __test_only_mutableState: MutableState {
        stateAccess.__test_only_mutableState
    }
}

extension RequestWithTokenRefresh.StateAccess {
    var __test_only_mutableState: RequestWithTokenRefresh.MutableState {
        mutableState
    }
}
