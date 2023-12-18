///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

@objc
open class DBXTestData: NSObject {
    @objc static var testId: String { get { TestData.testId } set { TestData.testId = newValue } }
    @objc static var baseFolder: String { get { TestData.baseFolder } set { TestData.baseFolder = newValue } }

    @objc static var testFolderName: String { get { TestData.testFolderName } set { TestData.testFolderName = newValue } }
    @objc static var testFolderPath: String { get { TestData.testFolderPath } set { TestData.testFolderPath = newValue } }

    @objc static var testShareFolderName: String { get { TestData.testShareFolderName } set { TestData.testShareFolderName = newValue } }
    @objc static var testShareFolderPath: String { get { TestData.testShareFolderPath } set { TestData.testShareFolderPath = newValue } }

    @objc static var testFileName: String { get { TestData.testFileName } set { TestData.testFileName = newValue } }
    @objc static var testFilePath: String { get { TestData.testFilePath } set { TestData.testFilePath = newValue } }

    @objc static var testData: String { get { TestData.testData } set { TestData.testData = newValue } }

    @objc static var fileData: Data { get { TestData.fileData } set { TestData.fileData = newValue } }
    @objc static var fileManager: FileManager { get { TestData.fileManager } set { TestData.fileManager = newValue } }
    @objc static var directoryURL: URL { get { TestData.directoryURL } set { TestData.directoryURL = newValue } }
    @objc static var destURL: URL { get { TestData.destURL } set { TestData.destURL = newValue } }

    @objc static var accountId: String { get { TestData.accountId } set { TestData.accountId = newValue } }
    @objc static var accountId2: String { get { TestData.accountId2 } set { TestData.accountId2 = newValue } }
    @objc static var accountId3: String { get { TestData.accountId3 } set { TestData.accountId3 = newValue } }
    @objc static var accountId3Email: String { get { TestData.accountId3Email } set { TestData.accountId3Email = newValue } }

    @objc static var testIdTeam: String { get { TestData.testIdTeam } set { TestData.testIdTeam = newValue } }
    @objc static var groupName: String { get { TestData.groupName } set { TestData.groupName = newValue } }
    @objc static var groupExternalId: String { get { TestData.groupExternalId } set { TestData.groupExternalId = newValue } }
    @objc static var groupExternalIdDashObjc: String { TestData.groupExternalId + "-objc" }

    @objc static var teamMemberEmail: String { get { TestData.teamMemberEmail } set { TestData.teamMemberEmail = newValue } }
    @objc static var newMemberEmail: String { get { TestData.newMemberEmail } set { TestData.newMemberEmail = newValue } }

    @objc static var fullDropboxAppKey: String { get { TestData.fullDropboxAppKey } set { TestData.fullDropboxAppKey = newValue } }
    @objc static var fullDropboxAppSecret: String { get { TestData.fullDropboxAppSecret } set { TestData.fullDropboxAppSecret = newValue } }
}
