import Foundation

/// Similar to `DBGlobalErrorResponseHandler` in the Objc SDK
/// It does not have special handling for route errors, which end up type-erased right now
/// It also does not allow you to easily retry requests yet, like Objc's does.
public class GlobalErrorResponseHandler {
    static var shared = { GlobalErrorResponseHandler() }()
    
    private struct Handler {
        let callback: (CallError<Any>) -> Void
        let queue: OperationQueue
    }
    
    // Locked state
    private struct State {
        var handlers: [Handler] = []
    }
    
    private var state = UnfairLock<State>(value: State())
    
    internal init() { }
    
    func reportGlobalError(_ error: CallError<Any>) {
        state.read { lockedState in
            lockedState.handlers.forEach { handler in
                handler.queue.addOperation {
                    handler.callback(error)
                }
            }
        }
    }
    
    func registerGlobalErrorHandler(_ callback: @escaping (CallError<Any>) -> Void, queue: OperationQueue = .main) {
        state.mutate { lockedState in
            lockedState.handlers.append(Handler(callback: callback, queue: queue))
        }
    }
}
