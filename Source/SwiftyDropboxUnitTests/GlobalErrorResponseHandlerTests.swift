import XCTest
@testable import SwiftyDropbox

class GlobalErrorResponseHandlerTests: XCTestCase {
    private var handler: GlobalErrorResponseHandler!
    override func setUp() {
        handler = GlobalErrorResponseHandler()
        super.setUp()
    }
    
    func testGlobalHandlerReportsNonRouteError() {
        let error = CallError<String>.internalServerError(567, "abc", "def")
        let expectation = XCTestExpectation(description: "Callback is called")
        handler.registerGlobalErrorHandler { error in
            guard case .internalServerError(let code, let message, let requestId) = error else {
                return XCTFail("Expected error")
            }
            XCTAssertEqual(code, 567)
            XCTAssertEqual(message, "abc")
            XCTAssertEqual(requestId, "def")
            expectation.fulfill()
        }
        handler.reportGlobalError(error.typeErased)
    }
    
    func testGlobalHandlerReportsRouteError() {
        let error = CallError<String>.routeError(Box("value"), LocalizedUserMessage(text: "ábc", locale: "EN-US"), "abc", "def")
        let expectation = XCTestExpectation(description: "Callback is called")
        handler.registerGlobalErrorHandler { error in
            guard case .routeError(let boxedValue, let locMessage, let message, let requestId) = error else {
                return XCTFail("Expected error")
            }
            XCTAssertEqual(boxedValue.unboxed as? String, "value")
            XCTAssertEqual(locMessage?.text, "ábc")
            XCTAssertEqual(locMessage?.locale, "EN-US")
            XCTAssertEqual(message, "abc")
            XCTAssertEqual(requestId, "def")
            expectation.fulfill()
        }
        handler.reportGlobalError(error.typeErased)
    }
}

class CallErrorTypeErasureTests: XCTestCase {
    let cases: [CallError<String>] = [
        .internalServerError(567, "abc", "def"),
        .badInputError("abc", "def"),
        .rateLimitError(.init(reason: .tooManyRequests), LocalizedUserMessage(text: "ábc", locale: "EN-US"), "abc", "def"),
        .httpError(456, "abc", "def"),
        .authError(Auth.AuthError.userSuspended, LocalizedUserMessage(text: "ábc", locale: "EN-US"), "abc", "def"),
        .accessError(Auth.AccessError.other, LocalizedUserMessage(text: "ábc", locale: "EN-US"), "abc", "def"),
        .routeError(Box("value"), LocalizedUserMessage(text: "ábc", locale: "EN-US"), "abc", "def"),
        .serializationError(SerializationError.missingResultData),
        .reconnectionError(ReconnectionError(reconnectionErrorKind: .badPersistedStringFormat, taskDescription: "bad")),
        .clientError(.unexpectedState),
    ]
    func testErrorTypeErasureProvidesSameDescription() {
        for error in cases {
            let typeErased = error.typeErased
            XCTAssertEqual(typeErased.description, error.description)
        }
    }
}
