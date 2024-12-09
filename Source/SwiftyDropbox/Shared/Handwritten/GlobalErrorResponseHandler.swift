import Foundation

/// Similar to `DBGlobalErrorResponseHandler` in the Objc SDK
/// It does not have special handling for route errors, which end up type-erased right now
/// It also does not allow you to easily retry requests yet, like Objc's does.
public class GlobalErrorResponseHandler {
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
    
    @discardableResult
    public func registerGlobalErrorHandler(_ callback: @escaping (CallError<Any>) -> Void, queue: OperationQueue = .main) -> String {
        let key = UUID().uuidString
        state.mutate { lockedState in
            lockedState.handlers[key] = Handler(callback: callback, queue: queue)
        }
        return key
    }
    
    public func deregisterGlobalErrorHandler(key: String) {
        state.mutate { lockedState in
            lockedState.handlers[key] = nil
        }
    }
    
    public func deregisterAllGlobalErrorHandlers() {
        state.mutate { lockedState in
            lockedState.handlers = [:]
        }
    }
}
