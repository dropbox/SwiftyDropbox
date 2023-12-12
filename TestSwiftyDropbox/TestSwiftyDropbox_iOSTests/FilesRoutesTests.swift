//
//  FilesRoutesTests.swift
//  FilesRoutesTests
//
//  Created by jlocke on 5/20/21.
//  Copyright © 2021 Dropbox. All rights reserved.
//

import XCTest
#if os(OSX)
@testable import TestSwiftyDropbox_macOS
#elseif os(iOS)
@testable import TestSwiftyDropbox_iOS
#endif

@testable import SwiftyDropbox

class FilesRoutesTests: XCTestCase {
    private var userClient: UsersRoutes!
    private var tester: DropboxTester!

    override func setUp() {
        print("[DEBUG CI HANG] setUp start")

        // You need an API app with the "Full Dropbox" permission type and at least the scopes in DropboxTester.scopes
        // and no team scopes.
        // You can create one for testing here: https://www.dropbox.com/developers/apps/create
        // The 'App key' will be on the app's info page.
        // Then follow https://dropbox.tech/developers/pkce--what-and-why- to get a refresh token using the PKCE flow

        continueAfterFailure = false

        print("[DEBUG CI HANG] setUp 1")
        if DropboxClientsManager.authorizedClient == nil {
            print("[DEBUG CI HANG] setUp 2")
            setupDropboxClientsManager()
        }

        print("[DEBUG CI HANG] setUp 3")
        userClient = DropboxClientsManager.authorizedClient!.users!
        print("[DEBUG CI HANG] setUp 4")
        tester = DropboxTester()
        print("[DEBUG CI HANG] setUp end")
    }

    func setupDropboxClientsManager() {
        print("[DEBUG CI HANG] setupDropboxClientsManager start")

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

        print("[DEBUG CI HANG] setupDropboxClientsManager token generated")

        #if os(OSX)
        DropboxClientsManager.setupWithAppKeyDesktop(apiAppKey, transportClient: transportClient) // could be getting here
        #elseif os(iOS)
        DropboxClientsManager.setupWithAppKey(apiAppKey, transportClient: transportClient)
        #endif
        print("[DEBUG CI HANG] setupDropboxClientsManager end")
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
        print("[DEBUG CI HANG] testFileRoutes 1")

        let flag = XCTestExpectation()

        let nextTest = {
            flag.fulfill()
        }

        print("[DEBUG CI HANG] testFileRoutes 2")
        tester.testFilesActions(nextTest, asMember: false)

        print("[DEBUG CI HANG] testFileRoutes 3")

        let result = XCTWaiter.wait(for: [flag], timeout: 60 * 5)
        print("[DEBUG CI HANG] testFileRoutes 4")

        XCTAssertEqual(result, .completed, "Error: timeout on file routes tests")
        print("[DEBUG CI HANG] testFileRoutes 5")
    }
}
