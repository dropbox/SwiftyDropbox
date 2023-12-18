///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

final class TestMobileOAuthImpl: XCTestCase {
    var sut: DropboxOAuthManager!
    var mockNetworkSession: MockNetworkSession!
    var mockSecureStorageAccess: MockSecureStorageAccess!

    let appKey = "appkey"
    let oauthTokenSecret = "oauth_token_secret"
    let refreshToken = "refresh_token"
    let accessToken = "access_token"
    let userId = "user_id"
    let userIdTwo = "user_id_2"
    let state = "state"

    override func setUpWithError() throws {
        mockNetworkSession = MockNetworkSession()
        mockSecureStorageAccess = MockSecureStorageAccess()
        sut = DropboxMobileOAuthManager(
            appKey: appKey,
            host: "www.dropbox.com",
            secureStorageAccess: mockSecureStorageAccess,
            networkSession: mockNetworkSession,
            dismissSharedAppAuthController: {}
        )
    }

    func testHandleRedirectURLCancelsWhenCancelPathProvided() throws {
        let e = expectation(description: "completion called")

        let url = try URL(string: "db-\(appKey)://2/cancel").orThrow()

        _ = sut.handleRedirectURL(url) { result in
            XCTAssert(result == DropboxOAuthResult.cancel)
            e.fulfill()
        }

        wait(for: [e], timeout: 1)
    }

    func testHandleDauthRedirectURLStoresRecievesAndStoresTokenOnSuccess() throws {
        let e = expectation(description: "completion called")

        let url = try exampleRedirectUrl(appKey: appKey)

        // fake that we're in a pkce session + hardcode pkce state
        sut.authSession = OAuthPKCESession(scopeRequest: nil)
        sut.authSession?.__test_only_setState(value: state)

        mockNetworkSession.mockInputs["OAuthTokenRequest"] = .success(json: [
            "token_type": "bearer",
            "expires_in": 14_400,
            "account_id": "dbid:some_account",
            "refresh_token": refreshToken,
            "scope": "account_info.read",
            "access_token": "access_token",
            "uid": userId,
        ])

        let expectedToken = DropboxAccessToken(
            accessToken: accessToken,
            uid: userId,
            refreshToken: refreshToken,
            tokenExpirationTimestamp: Date().timeIntervalSince1970
        )

        _ = sut.handleRedirectURL(url) { result in
            if case .success(let token) = result {
                // expect token info passed through
                XCTAssertEqual(token.accessToken, expectedToken.accessToken)
                XCTAssertEqual(token.uid, expectedToken.uid)
                XCTAssertEqual(token.refreshToken, expectedToken.refreshToken)

                // expect token stored
                XCTAssertEqual(self.mockSecureStorageAccess.setAccessTokenDataPassed?.0, expectedToken.uid)
            } else {
                XCTFail()
            }

            e.fulfill()
        }

        wait(for: [e], timeout: 1)
    }

    func testAccessTokenProviderForTokenReturnsCorrectProviderType() throws {
        let longLivedToken = DropboxAccessToken(accessToken: accessToken, uid: userId)
        let shortLivedToken = DropboxAccessToken(
            accessToken: accessToken,
            uid: userId,
            refreshToken: refreshToken,
            tokenExpirationTimestamp: Date().timeIntervalSince1970
        )

        let expectShortLivedAccessProvider = sut.accessTokenProviderForToken(shortLivedToken)
        let expectLongLivedAccessProvider = sut.accessTokenProviderForToken(longLivedToken)

        XCTAssertTrue(expectLongLivedAccessProvider is LongLivedAccessTokenProvider)
        XCTAssertTrue(expectShortLivedAccessProvider is ShortLivedAccessTokenProvider)
    }

    func testAccessTokensAreRetrievedFromSecureStorage() throws {
        mockSecureStorageAccess.userIdsToTokens = exampleAccessTokenData()

        let fetchedTokens = sut.getAllAccessTokens().count

        XCTAssertEqual(exampleAccessTokenData().count, fetchedTokens)
    }

    func testAccessTokenIsStoredInSecureStorage() throws {
        let tokenToStore = exampleShortLivedAccessToken()

        sut.storeAccessToken(exampleShortLivedAccessToken())

        XCTAssertEqual(mockSecureStorageAccess.setAccessTokenDataPassed?.0, tokenToStore.uid)
    }

    func testCheckAccessibilityMigrationOneTimeCallsThroughToSecureStorage() throws {
        sut.checkAccessibilityMigrationOneTime()

        XCTAssertTrue(mockSecureStorageAccess.migrationCheckCalled)
    }

    func testURLSchemeRejectsIncorrectAppKeys() throws {
        let e = expectation(description: "completion called")

        let url = try exampleRedirectUrl(appKey: "bad-app-key")

        _ = sut.handleRedirectURL(url) { result in
            XCTAssertNil(result)
            e.fulfill()
        }

        wait(for: [e], timeout: 1)
    }

    // MARK: Helpers

    func exampleLongLivedAccessToken() -> DropboxAccessToken {
        DropboxAccessToken(accessToken: accessToken, uid: userId)
    }

    func exampleShortLivedAccessToken() -> DropboxAccessToken {
        DropboxAccessToken(accessToken: accessToken, uid: userIdTwo, refreshToken: refreshToken, tokenExpirationTimestamp: Date().timeIntervalSince1970)
    }

    func exampleAccessTokenData() -> [String: DropboxAccessToken] {
        [
            userId: exampleLongLivedAccessToken(),
            userIdTwo: exampleShortLivedAccessToken(),
        ]
    }

    func exampleRedirectUrl(appKey: String) throws -> URL {
        try URL(string: "db-\(appKey)://1/connect?oauth_token_secret=\(oauthTokenSecret)&uid=\(userId)&state=\(state)&oauth_token=oauth2code%3A").orThrow()
    }
}

class MockSecureStorageAccess: SecureStorageAccess {
    var migrationCheckCalled = false
    var setAccessTokenDataPassed: (String, Data)?
    var deleteInfoCalled = false
    var deleteInfoForAllKeysCalled = false

    var userIdsToTokens: [String: DropboxAccessToken] = [:]

    func checkAccessibilityMigrationOneTime() {
        migrationCheckCalled = true
    }

    func setAccessTokenData(for userId: String, data: Data) -> Bool {
        setAccessTokenDataPassed = (userId, data)
        return true
    }

    func getAllUserIds() -> [String] {
        Array(userIdsToTokens.keys)
    }

    func getDropboxAccessToken(for key: String) -> SwiftyDropbox.DropboxAccessToken? {
        userIdsToTokens[key]
    }

    func deleteInfo(for key: String) -> Bool {
        fatalError()
    }

    func deleteInfoForAllKeys() -> Bool {
        fatalError()
    }
}
