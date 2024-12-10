import XCTest
@testable import SwiftyDropbox

class GlobalErrorResponseHandlerTests: XCTestCase {
    private var handler: GlobalErrorResponseHandler!
    override func setUp() {
        handler = GlobalErrorResponseHandler()
        super.setUp()
    }
    
    func testGlobalHandlerReportsNonRouteError() {
        let error = CallError<String>.authError(Auth.AuthError.expiredAccessToken, LocalizedUserMessage(text: "ábc", locale: "EN-US"), "abc", "def")
        let expectation = XCTestExpectation(description: "Callback is called")
        handler.registerGlobalErrorHandler { error in
            guard case .authError(let authError, let locMessage, let message, let requestId) = error else {
                return XCTFail("Expected error")
            }
            do {
                let authErrorJson = try authError.json()
                let expectedJson = try Auth.AuthError.expiredAccessToken.json()
                XCTAssertEqual(authErrorJson, expectedJson)
            } catch {
                XCTFail("Error serializing auth error")
            }
            XCTAssertEqual(locMessage?.text, "ábc")
            XCTAssertEqual(locMessage?.locale, "EN-US")
            XCTAssertEqual(message, "abc")
            XCTAssertEqual(requestId, "def")
            expectation.fulfill()
        }
        handler.reportGlobalError(error.typeErased)
        wait(for: [expectation], timeout: 1)
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
        wait(for: [expectation], timeout: 1)
    }
    
    func testDeregisterGlobalHandler() {
        let expectation = XCTestExpectation(description: "Callback is called")
        expectation.isInverted = true
        let key = handler.registerGlobalErrorHandler { error in
            expectation.fulfill()
            XCTFail("Should not be called")
        }
        handler.deregisterGlobalErrorHandler(key: key)
        let error = CallError<String>.authError(Auth.AuthError.expiredAccessToken, LocalizedUserMessage(text: "ábc", locale: "EN-US"), "abc", "def")
        handler.reportGlobalError(error.typeErased)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testDeregisterAllGlobalHandlers() {
        let expectation = XCTestExpectation(description: "Callback is called")
        expectation.isInverted = true
        _ = handler.registerGlobalErrorHandler { error in
            expectation.fulfill()
            XCTFail("Should not be called")
        }
        _ = handler.registerGlobalErrorHandler { error in
            expectation.fulfill()
            XCTFail("Should not be called")
        }
        handler.deregisterAllGlobalErrorHandlers()
        let error = CallError<String>.authError(Auth.AuthError.expiredAccessToken, LocalizedUserMessage(text: "ábc", locale: "EN-US"), "abc", "def")
        handler.reportGlobalError(error.typeErased)
        
        wait(for: [expectation], timeout: 1)
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

class RequestGlobalErrorHandlerIntegrationTests: XCTestCase {
    
    var client: DropboxClient!
    var mockTransportClient: MockDropboxTransportClient!
    
    override func setUp() {
        mockTransportClient = MockDropboxTransportClient()
        client = DropboxClient(transportClient: mockTransportClient)
        super.setUp()
    }
    
    override func tearDown() {
        // GlobalErrorResponseHandler.shared.removeAllHandlers()
        super.tearDown()
    }
    
    func testRpcRequestGlobalErrorHandler() {
        let handler = GlobalErrorResponseHandler.shared
        let globalExpectation = XCTestExpectation(description: "Callback is called")
        let key = handler.registerGlobalErrorHandler { error in
            guard case .authError(let authError, _, _, _) = error else {
                return XCTFail("Expected error")
            }
            do {
                let authErrorJson = try authError.json()
                let expectedJson = try Auth.AuthError.expiredAccessToken.json()
                XCTAssertEqual(authErrorJson, expectedJson)
            } catch {
                XCTFail("Error serializing auth error")
            }
            globalExpectation.fulfill()
        }
        
        mockTransportClient.mockRequestHandler = { request in
            try? request.handleMockInput(.requestError(model: Auth.AuthError.expiredAccessToken, code: 401))
        }
        
        let completionHandlerExpectation = XCTestExpectation(description: "Callback is called")
        client.check.user().response { _, error in
            XCTAssertNotNil(error)
            completionHandlerExpectation.fulfill()
        }
        
        handler.deregisterGlobalErrorHandler(key: key)
        wait(for: [globalExpectation, completionHandlerExpectation], timeout: 1)
    }
    
    func testDownloadRequestGlobalErrorHandler() {
        let handler = GlobalErrorResponseHandler.shared
        let globalExpectation = XCTestExpectation(description: "Callback is called")
        let key = handler.registerGlobalErrorHandler { error in
            guard case .authError(let authError, _, _, _) = error else {
                return XCTFail("Expected error")
            }
            do {
                let authErrorJson = try authError.json()
                let expectedJson = try Auth.AuthError.expiredAccessToken.json()
                XCTAssertEqual(authErrorJson, expectedJson)
            } catch {
                XCTFail("Error serializing auth error")
            }
            globalExpectation.fulfill()
        }
        
        mockTransportClient.mockRequestHandler = { request in
            try? request.handleMockInput(.requestError(model: Auth.AuthError.expiredAccessToken, code: 401))
        }
        
        let completionHandlerExpectation = XCTestExpectation(description: "Callback is called")
        client.files.download(path: "/test/path.pdf").response { _, error in
            XCTAssertNotNil(error)
            completionHandlerExpectation.fulfill()
        }
        
        handler.deregisterGlobalErrorHandler(key: key)
        wait(for: [globalExpectation, completionHandlerExpectation], timeout: 1)
    }
    
    func testUploadRequestGlobalErrorHandler() {
        let handler = GlobalErrorResponseHandler.shared
        let globalExpectation = XCTestExpectation(description: "Callback is called")
        let key = handler.registerGlobalErrorHandler { error in
            guard case .authError(let authError, _, _, _) = error else {
                return XCTFail("Expected error")
            }
            do {
                let authErrorJson = try authError.json()
                let expectedJson = try Auth.AuthError.expiredAccessToken.json()
                XCTAssertEqual(authErrorJson, expectedJson)
            } catch {
                XCTFail("Error serializing auth error")
            }
            globalExpectation.fulfill()
        }
        
        mockTransportClient.mockRequestHandler = { request in
            try? request.handleMockInput(.requestError(model: Auth.AuthError.expiredAccessToken, code: 401))
        }
        
        let completionHandlerExpectation = XCTestExpectation(description: "Callback is called")
        guard let testData = "test".data(using: .utf8) else {
            XCTFail("Failed to create test data")
            return
        }
        client.files.upload(path: "/test/path.pdf", input: testData).response { _, error in
            XCTAssertNotNil(error)
            completionHandlerExpectation.fulfill()
        }
        
        handler.deregisterGlobalErrorHandler(key: key)
        wait(for: [globalExpectation, completionHandlerExpectation], timeout: 1)
    }
}
