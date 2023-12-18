//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

import XCTest
#if os(OSX)
@testable import TestSwiftyDropbox_macOS
#elseif os(iOS)
@testable import TestSwiftyDropbox_iOS
#endif

@testable import SwiftyDropbox

class CustomRoutesTests: XCTestCase {
    private var userClient: UsersRoutes!
    private var tester: DropboxTester!

    override func setUp() {
        // You need an API app with the "Full Dropbox" permission type and at least the scopes in DropboxTester.scopes
        // and no team scopes.
        // You can create one for testing here: https://www.dropbox.com/developers/apps/create
        // The 'App key' will be on the app's info page.
        // Then follow https://dropbox.tech/developers/pkce--what-and-why- to get a refresh token using the PKCE flow

        continueAfterFailure = false

        if DropboxClientsManager.authorizedClient == nil {
            setupDropboxClientsManager()
        }

        userClient = DropboxClientsManager.authorizedClient!.users!
        tester = DropboxTester()
    }

    func setupDropboxClientsManager() {
        let processInfo = ProcessInfo.processInfo.environment

        guard let apiAppKey = processInfo["FULL_DROPBOX_API_APP_KEY"] else {
            return XCTFail("FULL_DROPBOX_API_APP_KEY needs to be set in the test Scheme")
        }
        guard let refreshToken = processInfo["FULL_DROPBOX_TESTER_USER_REFRESH_TOKEN"] else {
            return XCTFail("FULL_DROPBOX_TESTER_USER_REFRESH_TOKEN needs to be set in the test Scheme")
        }

        guard let transportClient = TestAuthTokenGenerator.transportClient(with: refreshToken, apiKey: apiAppKey, scopes: DropboxTester.scopes) else {
            return XCTFail("Error: Access token creation failed")
        }

        #if os(OSX)
        DropboxClientsManager.setupWithAppKeyDesktop(apiAppKey, transportClient: transportClient, secureStorageAccess: SecureStorageAccessTestImpl())
        #elseif os(iOS)
        DropboxClientsManager.setupWithAppKey(apiAppKey, transportClient: transportClient, secureStorageAccess: SecureStorageAccessTestImpl())
        #endif
    }

    override func tearDown() {
        print("tearDown: delete folder")
        let flag = XCTestExpectation()

        FilesTests(tester: tester).deleteV2 {
            flag.fulfill()
        }

        _ = XCTWaiter.wait(for: [flag], timeout: 30) // don't need to check result on tear down
    }

    func testFileRoutes() {
        let flag = XCTestExpectation()

        let nextTest = {
            flag.fulfill()
        }

        tester.testCustomActions(nextTest)

        let result = XCTWaiter.wait(for: [flag], timeout: 60 * 5)
        XCTAssertEqual(result, .completed, "Error: timeout on file routes tests")
    }
}
