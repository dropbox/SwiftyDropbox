///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

open class TestData {
    // to avoid name collisions in the event of leftover test state from failure
    static var testId = String(arc4random_uniform(1000))

    static var baseFolder = "/Testing/SwiftyDropboxTests"

    static var testFolderName = "testFolder"
    static var testFolderPath = baseFolder + "/" + testFolderName + "_" + testId

    static var testShareFolderName = "testShareFolder"
    static var testShareFolderPath = baseFolder + "/" + testShareFolderName + "_" + testId

    static var testFileName = "testFile"
    static var testFilePath = testFolderPath + "/" + testFileName

    static var testData = "testing data example"

    static var fileData = testData.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    static var fileManager = FileManager.default
    static var directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    static var destURL = directoryURL.appendingPathComponent(testFileName)

    static var destURLException = directoryURL.appendingPathComponent(testFileName + "_does_not_exist")
    static var destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
        return destURL
    }
    static var destinationException: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
        return destURLException
    }


    // user-specific information

    // account ID of the user you OAuth linked with in order to test
    static var accountId = "<ACCOUNT_ID1>"
    // any additional valid Dropbox account ID
    static var accountId2 = "<ACCOUNT_ID2>"
    // any additional valid Dropbox account ID
    static var accountId3 = "<ACCOUNT_ID3>"
    // the email address of the account whose account ID is `accoundId3`
    static var accountId3Email = "<ACCOUNT_ID3_EMAIL>"
    
    // team-specific data
    
    // to avoid name collisions in the event of leftover test state from failure
    static var testIdTeam = String(arc4random_uniform(1000))
    
    static var groupName = "GroupName" + testIdTeam
    static var groupExternalId = "group-" + testIdTeam
    
    
    // user-specific information
    
    // email address of the team user you OAuth link with in order to test
    static var teamMemberEmail = "<TEAM_MEMBER_EMAIL>"
    static var newMemberEmail = "<NEW_MEMBER_EMAIL>"
    
    // App key and secret
    static var fullDropboxAppKey = "<FULL_DROPBOX_APP_KEY>";
    static var fullDropboxAppSecret = "<FULL_DROPBOX_APP_SECRET>";
}

open class TestTeamData {
    
}
