//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation
@testable import SwiftyDropbox
import XCTest

class TestOAuthTokenRequest: XCTestCase {
    var sut: OAuthTokenRequest!
    var mockSession = MockNetworkSession()

    // MARK: Request creation

    func testThatRefreshRequestIsWellFormed() throws {
        // Given
        sut = OAuthTokenRefreshRequest(
            dataTaskCreation: mockSession.dataTask(request:networkTaskTag:completionHandler:),
            uid: "uid",
            refreshToken: "refreshToken",
            scopes: ["scope-1", "scope-2"],
            appKey: "appKey",
            locale: "locale"
        )

        // When
        let result = sut.request

        // Then
        XCTAssertEqual(result.httpMethod, "POST")

        XCTAssertQueryStringEqual(
            String(data: sut.request.httpBody ?? .init(), encoding: .utf8),
            "refresh_token=refreshToken&locale=locale&client_id=appKey&scope=scope-1%20scope-2&grant_type=refresh_token"
        )

        XCTAssertNotNil(result.allHTTPHeaderFields)
        XCTAssertEqual(
            result.allHTTPHeaderFields?["Content-Type"],
            "application/x-www-form-urlencoded; charset=utf-8"
        )
    }

    func testThatExchangeRequestIsWellFormed() throws {
        // Given
        sut = OAuthTokenExchangeRequest(
            dataTaskCreation: mockSession.dataTask(request:networkTaskTag:completionHandler:),
            oauthCode: "oauthCode",
            codeVerifier: "codeVerifier",
            appKey: "appKey",
            locale: "locale",
            redirectUri: "redirectUri"
        )

        // When
        let result = sut.request

        // Then
        XCTAssertNotNil(result.httpBody)
        XCTAssertEqual(result.httpMethod, "POST")

        XCTAssertQueryStringEqual(
            String(data: sut.request.httpBody ?? .init(), encoding: .utf8),
            "client_id=appKey&code=oauthCode&code_verifier=codeVerifier&redirect_uri=redirectUri&grant_type=authorization_code&locale=locale"
        )

        XCTAssertEqual(
            result.allHTTPHeaderFields?["Content-Type"],
            "application/x-www-form-urlencoded; charset=utf-8"
        )
    }

    // MARK: Response handling

    func testThatRefreshRequestCompletesWithTokenGivenSucessfulResponse() throws {
        let e = expectation(description: "completion called")

        // Given
        let date = Date()
        sut = OAuthTokenRefreshRequest(
            dataTaskCreation: mockSession.dataTask(request:networkTaskTag:completionHandler:),
            uid: "uid",
            refreshToken: "refreshToken",
            scopes: ["scope-1", "scope-2"],
            appKey: "appKey",
            locale: "locale",
            date: date
        )

        // When
        var result: DropboxOAuthResult?
        mockSession.mockInputs["OAuthTokenRequest"] = .success(json: [
            "token_type": "bearer",
            "access_token": "accessToken",
            "expires_in": 3_600.0,
        ])

        sut.start { oauthResult in
            result = oauthResult
            e.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        XCTAssertEqual(result, .success(
            .init(
                accessToken: "accessToken",
                uid: "uid",
                refreshToken: "refreshToken",
                tokenExpirationTimestamp: date.addingTimeInterval(3_600).timeIntervalSince1970
            )
        ))
    }

    func testThatRefreshRequestCompletesWithErrorGivenBadJSONInResponse() throws {
        let e = expectation(description: "completion called")

        // Given
        sut = OAuthTokenRefreshRequest(
            dataTaskCreation: mockSession.dataTask(request:networkTaskTag:completionHandler:),
            uid: "uid",
            refreshToken: "refreshToken",
            scopes: ["scope-1", "scope-2"],
            appKey: "appKey",
            locale: "locale"
        )

        // When
        var result: DropboxOAuthResult?
        mockSession.mockInputs["OAuthTokenRequest"] = .success(json: [
            "access_token": "accessToken",
        ])

        sut.start { oauthResult in
            result = oauthResult
            e.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        XCTAssertEqual(result, .error(.unknown, "Invalid response."))
    }

    func testThatRefreshRequestCompletesWithErrorWithMessageGivenOAuth2ErrorResponse() throws {
        continueAfterFailure = false
        let e = expectation(description: "completion called")

        // Given
        let date = Date()
        sut = OAuthTokenRefreshRequest(
            dataTaskCreation: mockSession.dataTask(request:networkTaskTag:completionHandler:),
            uid: "uid",
            refreshToken: "refreshToken",
            scopes: ["scope-1", "scope-2"],
            appKey: "appKey",
            locale: "locale",
            date: date
        )

        // When
        var result: DropboxOAuthResult?
        mockSession.mockInputs["OAuthTokenRequest"] = .requestError(json: [
            "error": "unsupported_grant_type",
            "error_description": "errorDescription",
        ], code: 400)

        sut.start { oauthResult in
            result = oauthResult
            e.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        XCTAssertEqual(result, .error(OAuth2Error(errorCode: "unsupported_grant_type"), "errorDescription"))
    }

    // MARK: Helpers

    public func XCTAssertQueryStringEqual(
        _ expression1: @autoclosure () throws -> String?,
        _ expression2: @autoclosure () throws -> String?,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let sortedQueryItems: (String?) -> [URLQueryItem]? = { string in
            let components = string.flatMap { URLComponents(string: $0) }
            let sort: (URLQueryItem, URLQueryItem) -> Bool = { $0.name < $1.name }
            return components?.queryItems?.sorted(by: sort)
        }

        XCTAssertEqual(try sortedQueryItems(expression1()), try sortedQueryItems(expression2()))
    }
}
