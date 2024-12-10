import Foundation

/// Similar to `DBGlobalErrorResponseHandler` in the Objc SDK
/// It does not have special handling for route errors, which end up type-erased right now
/// It also does not allow you to easily retry requests yet, like Objc's does.
/// Call `registerGlobalErrorHandler` to register a global error handler callback
/// Call `deregisterGlobalErrorHandler` to deregister it
/// Call `deregisterAllGlobalErrorHandlers` to deregister all global error handler callbacks
public class GlobalErrorResponseHandler {
    /// Singleton instance of `GlobalErrorResponseHandler`
    public static var shared = { GlobalErrorResponseHandler() }()
    
    private struct Handler {
        let callback: (CallError<Any>) -> Void
        let queue: OperationQueue
    }
    
    // Locked state
    private struct State {
        var handlers: [String:Handler] = [:]
    }
    
    private var state = UnfairLock<State>(value: State())
    
    internal init() { }
    
    internal func reportGlobalError(_ error: CallError<Any>) {
        state.read { lockedState in
            lockedState.handlers.forEach { _, handler in
                handler.queue.addOperation {
                    handler.callback(error)
                }
            }
        }
    }
    
    
    /// Register a callback to be called in addition to the normal completion handler for a request.
    /// You can use the callback to accomplish global error handling, such as logging errors or logging a user out after an `AuthError`.
    /// - Parameters:
    ///   - callback: The function you'd like called when an error occurs, it is provided a type-erased `CallError` that you can switch on.  If you know the specific route error type you want to look for, you can unbox and cast the contained route error value to that type, in the case of a route error.
    ///   - queue: The queue on which the callback should be called.  Defaults to the main queue via `OperationQueue.main`.
    /// - Returns: A key you can use to deregister the callback later.  It's just a UUID string.
    @discardableResult
    public func registerGlobalErrorHandler(_ callback: @escaping (CallError<Any>) -> Void, queue: OperationQueue = .main) -> String {
        let key = UUID().uuidString
        state.mutate { lockedState in
            lockedState.handlers[key] = Handler(callback: callback, queue: queue)
        }
        return key
    }
    
    
    /// Remove a global error handler callback by its key
    /// - Parameter key: The key returned when you registered the callback
    public func deregisterGlobalErrorHandler(key: String) {
        state.mutate { lockedState in
            lockedState.handlers[key] = nil
        }
    }
    
    
    /// Remove all global error handler callbacks, regardless of key.
    public func deregisterAllGlobalErrorHandlers() {
        state.mutate { lockedState in
            lockedState.handlers = [:]
        }
    }
}
