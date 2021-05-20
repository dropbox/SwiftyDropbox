//
//  FilesRoutesTests.swift
//  FilesRoutesTests
//
//  Created by jlocke on 5/20/21.
//  Copyright © 2021 Dropbox. All rights reserved.
//

import XCTest
@testable import TestSwiftyDropbox_iOS
@testable import SwiftyDropbox

class FilesRoutesTests: XCTestCase {

    private var userClient: UsersRoutes!
    private var tester: DropboxTester!

    override func setUpWithError() throws {
        // You need an API app with the "Full Dropbox" permission type and at least the scopes in scopesForTeamRoutesTests
        // You can create one for testing here: https://www.dropbox.com/developers/apps/create
        // The 'App key' will be on the app's info page.
        // Then follow https://dropbox.tech/developers/pkce--what-and-why- to get a refresh token using the PKCE flow

        continueAfterFailure = false

        let processInfo = ProcessInfo.processInfo.environment

        guard let apiAppKey = processInfo["FULL_DROPBOX_API_APP_KEY"] else {
            return XCTFail("FULL_DROPBOX_API_APP_KEY needs to be set in the test Scheme")
        }
        guard let refreshToken = processInfo["FULL_DROPBOX_TESTER_USER_REFRESH_TOKEN"] else {
            return XCTFail("FULL_DROPBOX_TESTER_USER_REFRESH_TOKEN needs to be set in the test Scheme")
        }

        let scopes = "account_info.read files.content.read files.content.write files.metadata.read files.metadata.write".components(separatedBy: " ")
        guard let accessToken = TestAuthTokenGenerator.authToken(with: refreshToken, apiKey: apiAppKey, scopes: scopes) else {
            return XCTFail("Error: Access token creation failed")
        }

        let transportClient = DropboxTransportClient(accessToken: accessToken)
        DropboxClientsManager.setupWithAppKey(apiAppKey, transportClient: transportClient)
        userClient = DropboxClientsManager.authorizedClient!.users!
        tester = DropboxTester()
    }

    override func tearDownWithError() throws {
        print("tearDown: delete folder")
        let flag = XCTestExpectation()

        FilesTests(tester: tester).deleteV2 {
            flag.fulfill()
        }

        _ = XCTWaiter.wait(for: [flag], timeout: 30) // don't need to check result on tear down
    }

    func testFileRoutes() throws {
        let flag = XCTestExpectation()

        let nextTest = {
            flag.fulfill()
        }

        tester.testFilesActions(nextTest, asMember: false)

        let result = XCTWaiter.wait(for: [flag], timeout: 60*5)
        XCTAssertEqual(result, .completed, "Error: timeout on file routes tests")
    }

}
