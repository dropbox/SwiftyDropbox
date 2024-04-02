@testable import SwiftyDropbox
import XCTest

enum TestAuthTokenGenerator {
    static let testUid = "test" // non-empty string needed here as subsequent tokens will share the uid and macOS keychain drops the attribute if empty

    static func transportClient(with refreshToken: String, apiKey: String, scopes: [String]) -> DropboxTransportClient? {
        let manager = SwiftyDropbox.DropboxOAuthManager(appKey: apiKey, secureStorageAccess: SecureStorageAccessTestImpl())

        let defaultToken = DropboxAccessToken(
            accessToken: "",
            uid: Self.testUid,
            refreshToken: refreshToken,
            tokenExpirationTimestamp: 0
        )

        let flag = XCTestExpectation()

        var returnAccessToken: DropboxAccessToken?

        manager.refreshAccessToken(
            defaultToken,
            scopes: scopes,
            queue: DispatchQueue.global(qos: .userInitiated)
        ) { result in

            switch result {
            case .success(let authToken)?:
                returnAccessToken = authToken
            case .error(_, let description)?:
                XCTFail("Error: failed to refresh access token (\(description ?? "no description")")
            case .cancel?:
                XCTFail("Error: failed to refresh access token (cancelled)")
            case .none:
                XCTFail("Error: failed to refresh access token (no result)")
            }

            flag.fulfill()
        }

        let result = XCTWaiter.wait(for: [flag], timeout: 10)
        XCTAssertEqual(result, .completed, "Error: timeout refreshing access token")
        guard let accessToken = returnAccessToken else {
            XCTFail("AccessToken creation failed")
            fatalError("AccessToken creation failed")
        }
        return DropboxTransportClientImpl(accessTokenProvider: manager.accessTokenProviderForToken(accessToken))
    }
}
