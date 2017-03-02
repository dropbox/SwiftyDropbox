///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

open class TestData {
    // to avoid name collisions in the event of leftover test state from failure
    static let testId = String(arc4random_uniform(1000))

    static let baseFolder = "/Testing/SwiftyDropboxTests"

    static let testFolderName = "testFolder"
    static let testFolderPath = baseFolder + "/" + testFolderName + "_" + testId

    static let testShareFolderName = "testShareFolder"
    static let testShareFolderPath = baseFolder + "/" + testShareFolderName + "_" + testId

    static let testFileName = "testFile"
    static let testFilePath = testFolderPath + "/" + testFileName

    static let testData = "testing data example"

    static let fileData = testData.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    static let fileManager = FileManager.default
    static let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    static let destURL = directoryURL.appendingPathComponent(testFileName)

    static let destURLException = directoryURL.appendingPathComponent(testFileName + "_does_not_exist")
    static let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
        return destURL
    }
    static let destinationException: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
        return destURLException
    }


    // user-specific information

    // account ID of the user you OAuth linked with in order to test
    static let accountId = "<ACCOUNT_ID1>"
    // any additional valid Dropbox account ID
    static let accountId2 = "<ACCOUNT_ID2>"
    // any additional valid Dropbox account ID
    static let accountId3 = "<ACCOUNT_ID3>"
    // the email address of the account whose account ID is `accoundId3`
    static let accountId3Email = "<ACCOUNT_ID3_EMAIL>"
    
    // team-specific data
    
    // to avoid name collisions in the event of leftover test state from failure
    static let testIdTeam = String(arc4random_uniform(1000))
    
    static let groupName = "GroupName" + testIdTeam
    static let groupExternalId = "group-" + testIdTeam
    
    
    // user-specific information
    
    // email address of the team user you OAuth link with in order to test
    static let teamMemberEmail = "<TEAM_MEMBER_EMAIL>"
    static let newMemberEmail = "<NEW_MEMBER_EMAIL>"
    
    // App key and secret
    static let fullDropboxAppKey = "<FULL_DROPBOX_APP_KEY>";
    static let fullDropboxAppSecret = "<FULL_DROPBOX_APP_SECRET>";
    
    static let teamMemberFileAccessAppKey = "<TEAM_MEMBER_FILE_ACCESS_APP_KEY>";
    static let teamMemberFileAccessAppSecret = "<FULL_DROPBOX_APP_SECRET>";
    
    static let teamMemberManagementAppKey = "<TEAM_MEMBER_MANAGEMENT_APP_KEY>";
    static let teamMemberManagementAppSecret = "<TEAM_MEMBER_MANAGEMENT_APP_SECRET>";
}

open class TestTeamData {
    
}
