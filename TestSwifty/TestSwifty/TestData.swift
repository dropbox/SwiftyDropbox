import Foundation
import SwiftyDropbox

public class TestData {
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

    static let fileData = testData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    static let fileManager = NSFileManager.defaultManager()
    static let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    static let destURL = directoryURL.URLByAppendingPathComponent(testFileName)

    static let destURLException = directoryURL.URLByAppendingPathComponent(testFileName + "_does_not_exist")
    static let destination: (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
        return destURL!
    }
    static let destinationException: (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
        return destURLException!
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
}

public class TestTeamData {
    // to avoid name collisions in the event of leftover test state from failure
    static let testId = String(arc4random_uniform(1000))

    static let groupName = "GroupName" + testId
    static let groupExternalId = "group-" + testId


    // user-specific information

    // email address of the team user you OAuth link with in order to test
    static let teamMemberEmail = "<TEAM_MEMBER_EMAIL>"
    static let newMemberEmail = "<NEW_MEMBER_EMAIL>"
}
