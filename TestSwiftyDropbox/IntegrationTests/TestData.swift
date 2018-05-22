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
    static let accountId = "dbid:AABL4QRrY7tB9viLgPUqmjkzE6Fe5ujlnlE"
    // any additional valid Dropbox account ID
    static let accountId2 = "dbid:AABZqArm5N_YcH1YxpVbjEWkdzGkYQ6mkqk"
    // any additional valid Dropbox account ID
    static let accountId3 = "dbid:AABi4KhsNtI1RhK-uQINEWkim3ucF-ASWgE"
    // the email address of the account whose account ID is `accoundId3`
    static let accountId3Email = "scobbe502+test1@gmail.com"
    
    // team-specific data
    
    // to avoid name collisions in the event of leftover test state from failure
    static let testIdTeam = String(arc4random_uniform(1000))
    
    static let groupName = "GroupName" + testIdTeam
    static let groupExternalId = "group-" + testIdTeam
    
    
    // user-specific information
    
    // email address of the team user you OAuth link with in order to test
    static let teamMemberEmail = "scobbe502+dfb@gmail.com"
    static let newMemberEmail = "scobbe@yahoo.com"
    
    // App key and secret
    static let fullDropboxAppKey = "4adrwp5qg3jf2lz";
    static let fullDropboxAppSecret = "b8rah3119t9bgzy";
    
    static let teamMemberFileAccessAppKey = "ye8gk3g89l1qzti";
    static let teamMemberFileAccessAppSecret = "ih95mtheg11fxq2";
    
    static let teamMemberManagementAppKey = "58b6omn1ngccg9r";
    static let teamMemberManagementAppSecret = "tptdjks2gnoib7q";
}

open class TestTeamData {
    
}
