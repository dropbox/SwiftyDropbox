@testable import SwiftyDropbox
import XCTest

let TestUid = "test" // non-empty string needed here as subsequent tokens will share the uid and macOS keychain drops the attribute if empty
enum TestAuthTokenGenerator {
    static func transportClient(with refreshToken: String, apiKey: String, scopes: [String]) -> DropboxTransportClient? {
        print("[DEBUG CI HANG] transportClient 1")

        let manager = SwiftyDropbox.DropboxOAuthManager(appKey: apiKey, secureStorageAccess: SecureStorageAccesDefaultImpl())
        print("[DEBUG CI HANG] transportClient 2")

        let defaultToken = DropboxAccessToken(
            accessToken: "",
            uid: TestUid,
            refreshToken: refreshToken,
            tokenExpirationTimestamp: 0
        )
        print("[DEBUG CI HANG] transportClient 3")

        let flag = XCTestExpectation()
        print("[DEBUG CI HANG] transportClient 4")

        var returnAccessToken: DropboxAccessToken?
        print("[DEBUG CI HANG] transportClient 5")

        manager.refreshAccessToken(
            defaultToken,
            scopes: scopes,
            queue: DispatchQueue.global(qos: .userInitiated)
        ) { result in
            print("[DEBUG CI HANG] transportClient 6")

            switch result {
            case .success(let authToken)?:
                returnAccessToken = authToken
                print("[DEBUG CI HANG] transportClient 7")

            case .error(_, let description)?:
                print("[DEBUG CI HANG] transportClient 8")

                XCTFail("Error: failed to refresh access token (\(description ?? "no description")")
            case .cancel?:
                print("[DEBUG CI HANG] transportClient 9")

                XCTFail("Error: failed to refresh access token (cancelled)")
            case .none:
                print("[DEBUG CI HANG] transportClient 10")

                XCTFail("Error: failed to refresh access token (no result)")
            }
            print("[DEBUG CI HANG] transportClient 11")

            flag.fulfill()
        }
        print("[DEBUG CI HANG] transportClient 12")


        let result = XCTWaiter.wait(for: [flag], timeout: 10)
        print("[DEBUG CI HANG] transportClient 13")

        XCTAssertEqual(result, .completed, "Error: timeout refreshing access token")
        print("[DEBUG CI HANG] transportClient 14")

        guard let accessToken = returnAccessToken else {
            print("[DEBUG CI HANG] transportClient 15")

            XCTFail("AccessToken creation failed")
            fatalError("AccessToken creation failed")
        }
        print("[DEBUG CI HANG] transportClient 16")

        return DropboxTransportClientImpl(accessTokenProvider: manager.accessTokenProviderForToken(accessToken))
    }
}
