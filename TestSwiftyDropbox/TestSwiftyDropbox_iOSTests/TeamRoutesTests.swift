//
//  Copyright (c) 2020 Dropbox Inc. All rights reserved.
//

import XCTest
#if os(OSX)
@testable import TestSwiftyDropbox_macOS
#elseif os(iOS)
@testable import TestSwiftyDropbox_iOS
#endif
@testable import SwiftyDropbox

class TeamRoutesTests: XCTestCase {

    private var teamClient: TeamRoutes!
    private var tester: DropboxTeamTester!

    private let scopes = "groups.read groups.write members.delete members.read members.write sessions.list team_data.member team_info.read files.content.write files.content.read sharing.write account_info.read".components(separatedBy: " ")

    override func setUp() {
        // You need an API app with the "Full Dropbox" permission type and at least the scopes above
        // You can create one for testing here: https://www.dropbox.com/developers/apps/create
        // The 'App key' will be on the app's info page.
        // Then follow https://dropbox.tech/developers/pkce--what-and-why- to get a refresh token using the PKCE flow

        continueAfterFailure = false

        let processInfo = ProcessInfo.processInfo.environment

        guard let apiAppKey = processInfo["FULL_DROPBOX_API_APP_KEY"] else {
            return XCTFail("FULL_DROPBOX_API_APP_KEY needs to be set in the test Scheme")
        }
        guard let refreshToken = processInfo["FULL_DROPBOX_TESTER_TEAM_REFRESH_TOKEN"] else {
            return XCTFail("FULL_DROPBOX_TESTER_USER_REFRESH_TOKEN needs to be set in the test Scheme")
        }
        guard let accessToken = TestAuthTokenGenerator.authToken(with: refreshToken, apiKey: apiAppKey, scopes: scopes) else {
            return XCTFail("Error: Access token creation failed")
        }
        guard let teamMemberEmail = processInfo["TEAM_MEMBER_EMAIL"] else {
            return XCTFail("TEAM_MEMBER_EMAIL needs to be set in the test Scheme")
        }
        guard let emailToAddAsTeamMember = processInfo["EMAIL_TO_ADD_AS_TEAM_MEMBER"] else {
            return XCTFail("EMAIL_TO_ADD_AS_TEAM_MEMBER needs to be set in the test Scheme")
        }
        guard let accountId = processInfo["ACCOUNT_ID"] else {
            return XCTFail("ACCOUNT_ID needs to be set in the test Scheme")
        }
        guard let accountId2 = processInfo["ACCOUNT_ID_2"] else {
            return XCTFail("ACCOUNT_ID_2 needs to be set in the test Scheme")
        }
        guard let accountId3 = processInfo["ACCOUNT_ID_3"] else {
            return XCTFail("ACCOUNT_ID_3 needs to be set in the test Scheme")
        }

        let transportClient = DropboxTransportClient(accessToken: accessToken)

        DropboxOAuthManager.sharedOAuthManager = nil

        #if os(OSX)
            DropboxClientsManager.setupWithTeamAppKeyDesktop(apiAppKey, transportClient: transportClient)
        #elseif os(iOS)
            DropboxClientsManager.setupWithTeamAppKey(apiAppKey, transportClient: transportClient)
        #endif

        teamClient = DropboxClientsManager.authorizedTeamClient?.team

        TestData.teamMemberEmail = teamMemberEmail
        TestData.newMemberEmail = emailToAddAsTeamMember
        TestData.accountId3Email = emailToAddAsTeamMember

        TestData.accountId = accountId
        TestData.accountId2 = accountId2
        TestData.accountId3 = accountId3

        tester = DropboxTeamTester()
    }

    func testTeamMemberManagement() {
        let flag = XCTestExpectation()

        tester.testTeamMemberManagementActions {
            flag.fulfill()
        }

        let result = XCTWaiter.wait(for: [flag], timeout: 60*5)
        XCTAssertEqual(result, .completed, "Error: timeout on team management routes tests")
    }

    func testTeamMemberFileAccess() {
        let flag = XCTestExpectation()

        tester.testTeamMemberFileAcessActions(skipRevokeToken: true) {
            flag.fulfill()
        }

        let result = XCTWaiter.wait(for: [flag], timeout: 60*5)
        XCTAssertEqual(result, .completed, "Error: timeout on team management routes tests")
    }
}
