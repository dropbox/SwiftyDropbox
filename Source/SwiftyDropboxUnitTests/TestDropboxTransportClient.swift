///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

final class TestDropboxTransportClient: XCTestCase {
    var sut: DropboxTransportClient!
    var mockNetworkSession: MockNetworkSession!

    override func setUpWithError() throws {
        mockNetworkSession = MockNetworkSession()
    }

    func testAdditionalHeadersForRouteHostAreAddedToRequest() throws {
        sut = DropboxTransportClientImpl(accessToken: "", sessionCreation: { _, _, _ in
            mockNetworkSession
        }, headersForRouteHost: { _ in
            ["key1": "value1"]
        })

        let urlRequest = try createRequestAndReturnURLRequest(for: Check.user)

        XCTAssertEqual(
            urlRequest.allHTTPHeaderFields?["key1"],
            "value1"
        )
    }

    func testBaseAppHeadersAddedToRequest() throws {
        sut = DropboxTransportClientImpl(
            authStrategy: .appKeyAndSecret("appKey", "appSecret"),
            userAgent: "userAgent",
            selectUser: nil,
            sessionCreation: { _, _, _ in
                mockNetworkSession
            },
            authChallengeHandler: nil
        )

        let urlRequest = try createRequestAndReturnURLRequest(for: Check.app)

        let headers = try XCTUnwrap(urlRequest.allHTTPHeaderFields)

        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(headers["Authorization"], "Basic YXBwS2V5OmFwcFNlY3JldA==")
        XCTAssertEqual(headers["User-Agent"]?.contains("userAgent"), true)
    }

    func testBaseUserTeamHeadersAddedToRequest() throws {
        sut = DropboxTransportClientImpl(
            authStrategy: .accessToken(LongLivedAccessTokenProvider(accessToken: "accessToken")),
            userAgent: "userAgent",
            selectUser: nil,
            sessionCreation: { _, _, _ in
                mockNetworkSession
            },
            authChallengeHandler: nil
        )

        let urlRequest = try createRequestAndReturnURLRequest(for: Check.user)

        let headers = try XCTUnwrap(urlRequest.allHTTPHeaderFields)

        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(headers["Authorization"], "Bearer accessToken")
        XCTAssertEqual(headers["User-Agent"]?.contains("userAgent"), true)
    }

    func testUpdatingTransportClientAuthProviderUpdatesRequestAuthProvider() throws {
        let e = expectation(description: "Token provider is checked for refresh")

        // Create a transport client with an access token
        sut = DropboxTransportClientImpl(
            authStrategy: .accessToken(LongLivedAccessTokenProvider(accessToken: "accessToken")),
            userAgent: "userAgent",
            selectUser: nil,
            sessionCreation: { _, _, _ in
                mockNetworkSession
            },
            authChallengeHandler: nil
        )

        let mockAccessToken = MockAccessToken(expectation: e)

        // Update the transport client access token to the mocked one
        sut.accessTokenProvider = mockAccessToken

        let concreteDropboxTransportClient = try XCTUnwrap(sut as? DropboxTransportClientImpl)
        let apiRequestCreation = try XCTUnwrap(concreteDropboxTransportClient.manager.apiRequestCreation)

        createApiRequest(apiRequestCreation: apiRequestCreation)

        wait(for: [e], timeout: 1)

        // Verify that the mock access token was in fact used
        XCTAssert(mockAccessToken.refreshAccessTokenCalled)
    }

    private func createApiRequest(apiRequestCreation: @escaping ApiRequestCreation) {
        let urlRequest = URLRequest(url: .init(string: "www.example.com")!)
        let networkTaskCreation: NetworkTaskCreation = { MockNetworkTaskDelegate(request: urlRequest) }
        let onCreation: OnTaskCreation = { _ in }
        _ = apiRequestCreation(networkTaskCreation, onCreation)
    }

    private func createRequestAndReturnURLRequest<A, B, C>(for route: Route<A, B, C>) throws -> URLRequest {
        let request = sut.request(route)

        let maybeApiRequest = request.request
        let urlRequest = try urlRequest(from: maybeApiRequest)
        return urlRequest
    }

    private func urlRequest(from maybeApiRequest: ApiRequest?) throws -> URLRequest {
        let apiRequest = try XCTUnwrap(maybeApiRequest)

        let expectation = expectation(description: "request created")

        let requestImpl = try XCTUnwrap(apiRequest as? RequestWithTokenRefresh)

        requestImpl.__test_only_mutableState.__test_only_setOnRequestCreation {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)

        let maybeUrlRequest = apiRequest.networkTask?.originalRequest
        return try XCTUnwrap(maybeUrlRequest)
    }
}

class MockAccessToken: AccessTokenProvider {
    var accessToken: String = ""
    var expectation: XCTestExpectation
    var refreshAccessTokenCalled = false

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func refreshAccessTokenIfNecessary(completion: @escaping SwiftyDropbox.DropboxOAuthCompletion) {
        refreshAccessTokenCalled = true
        expectation.fulfill()
    }
}
