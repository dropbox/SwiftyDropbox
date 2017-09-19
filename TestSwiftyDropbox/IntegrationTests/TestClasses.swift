///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

open class DropboxTester {
    let auth = DropboxClientsManager.authorizedClient!.auth!
    let users = DropboxClientsManager.authorizedClient!.users!
    let files = DropboxClientsManager.authorizedClient!.files!
    let sharing = DropboxClientsManager.authorizedClient!.sharing!

    func testBatchUpload() {
        TestFormat.printSubTestBegin(NSStringFromSelector(#function))
        // create working folder
        let workingDirectoryName = "MyOutputFolder"
        let workingDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(workingDirectoryName)
        do {
            try FileManager.default.createDirectory(atPath: workingDirectory.path, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        var uploadFilesUrlsToCommitInfo: [URL: Files.CommitInfo] = [:]

        print("\n\nCreating files in: \(workingDirectory.path)\n\n")
        // create a bunch of fake files
        for i in 0..<10 {
            let fileName = "test_file_\(i)"
            let fileContent = "\(fileName)'s content. Test content here."
            let fileUrl = workingDirectory.appendingPathComponent(fileName)
            // set to test large file
            let testLargeFile: Bool = true
            // don't create a file for the name test_file_5 so we use a custom large file
            // there instead
            if i != 5 || !testLargeFile {
                do {
                    try fileContent.write(to: fileUrl, atomically: false, encoding: String.Encoding.utf8)
                }
                catch {
                    print("Error creating file")
                    print("Terminating...")
                    exit(0)
                }
            } else {
                if !FileManager.default.fileExists(atPath: fileUrl.path) {
                    print("\n\nPlease create a large file named \(fileUrl.lastPathComponent) to test chunked uploading\n\n")
                    exit(0)
                }
            }
            let commitInfo = Files.CommitInfo(path: "\(TestData.testFolderPath)/\(fileName)")
            uploadFilesUrlsToCommitInfo[fileUrl] = commitInfo
        }

        self.files.batchUploadFiles(fileUrlsToCommitInfo: uploadFilesUrlsToCommitInfo, progressBlock: { progress in
            print("Progress: \(progress)")
        }, responseBlock: { fileUrlsToBatchResultEntries, finishBatchRequestError, fileUrlsToRequestErrors in
            if let fileUrlsToBatchResultEntries = fileUrlsToBatchResultEntries {
                for (clientSideFileUrl, resultEntry) in fileUrlsToBatchResultEntries {
                    switch resultEntry {
                    case .success(let metadata):
                        let dropboxFilePath = metadata.pathDisplay!
                        print("File successfully uploaded from \(clientSideFileUrl.absoluteString) on local machine to \(dropboxFilePath) in Dropbox.")
                    case .failure(let error):
                        // This particular file was not uploaded successfully, although the other
                        // files may have been uploaded successfully. Perhaps implement some retry
                        // logic here based on `uploadError`
                        print("Error: \(error)")
                    }
                }
            } else if let finishBatchRequestError = finishBatchRequestError {
                print("Either bug in SDK code, or transient error on Dropbox server: \(finishBatchRequestError)")
            } else if fileUrlsToRequestErrors.count > 0 {
                print("Other additional errors (e.g. file doesn't exist client-side, etc.).")
                print("\(fileUrlsToRequestErrors)")
            }
        })
    }

    // Test user app with 'Full Dropbox' permission
    func testAllUserEndpoints(_ asMember: Bool = false, nextTest: (() -> Void)? = nil) {
        let end = {
            if let nextTest = nextTest {
                nextTest()
            } else {
                TestFormat.printAllTestsEnd()
            }
        }
        let testAuthActions = {
            self.testAuthActions(end)
        }
        let testUserActions = {
            self.testUserActions(testAuthActions)
        }
        let testSharingActions = {
            self.testSharingActions(testUserActions)
        }
        let start = {
            self.testFilesActions(testSharingActions, asMember: asMember)
        }

        start()
    }

    func testFilesActions(_ nextTest: @escaping (() -> Void), asMember: Bool = false) {
        let tester = FilesTests(tester: self)

        let end = {
            TestFormat.printTestEnd()
            nextTest()
        }
        let listFolderLongpollAndTrigger = {
            // route currently doesn't work with Team app performing 'As Member'
            tester.listFolderLongpollAndTrigger(end, asMember: asMember)
        }
        let uploadFile = {
            tester.uploadFile(listFolderLongpollAndTrigger)
        }
        let downloadToMemory = {
            tester.downloadToMemory(uploadFile)
        }
        let downloadError = {
            tester.downloadError(downloadToMemory)
        }
        let downloadAgain = {
            tester.downloadAgain(downloadError)
        }
        let downloadToFile = {
            tester.downloadToFile(downloadAgain)
        }
        let saveUrl = {
            // route currently doesn't work with Team app performing 'As Member'
            tester.saveUrl(downloadToFile, asMember: asMember)
        }
        let listRevisions = {
            tester.listRevisions(saveUrl)
        }
        let getTemporaryLink = {
            tester.getTemporaryLink(listRevisions)
        }
        let getMetadataInvalid = {
            tester.getMetadataInvalid(getTemporaryLink)
        }
        let getMetadata = {
            tester.getMetadata(getMetadataInvalid)
        }
        let copyReferenceGet = {
            tester.copyReferenceGet(getMetadata)
        }
        let copyV2 = {
            tester.copyV2(copyReferenceGet)
        }
        let uploadDataSession = {
            tester.uploadDataSession(copyV2)
        }
        let uploadData = {
            tester.uploadData(uploadDataSession)
        }
        let listFolder = {
            tester.listFolder(uploadData)
        }
        let createFolderV2 = {
            tester.createFolderV2(listFolder)
        }
        let deleteV2 = {
            tester.deleteV2(createFolderV2)
        }
        let start = {
            deleteV2()
        }

        TestFormat.printTestBegin(#function)
        start()
    }

    func testSharingActions(_ nextTest: @escaping (() -> Void)) {
        let tester = SharingTests(tester: self)

        let end = {
            TestFormat.printTestEnd()
            nextTest()
        }
        let unshareFolder = {
            tester.unshareFolder(end)
        }
        let updateFolderPolicy = {
            tester.updateFolderPolicy(unshareFolder)
        }
        let mountFolder = {
            tester.mountFolder(updateFolderPolicy)
        }
        let unmountFolder = {
            tester.unmountFolder(mountFolder)
        }
        let revokeSharedLink = {
            tester.revokeSharedLink(unmountFolder)
        }
        let removeFolderMember = {
            tester.removeFolderMember(revokeSharedLink)
        }
        let listSharedLinks = {
            tester.listSharedLinks(removeFolderMember)
        }
        let listFolders = {
            tester.listFolders(listSharedLinks)
        }
        let listFolderMembers = {
            tester.listFolderMembers(listFolders)
        }
        let addFolderMember = {
            tester.addFolderMember(listFolderMembers)
        }
        let getSharedLinkMetadata = {
            tester.getSharedLinkMetadata(addFolderMember)
        }
        let getFolderMetadata = {
            tester.getFolderMetadata(getSharedLinkMetadata)
        }
        let createSharedLinkWithSettings = {
            tester.createSharedLinkWithSettings(getFolderMetadata)
        }
        let shareFolder = {
            tester.shareFolder(createSharedLinkWithSettings)
        }
        let start = {
            shareFolder()
        }

        TestFormat.printTestBegin(#function)
        start()
    }

    func testUserActions(_ nextTest: @escaping (() -> Void)) {
        let tester = UserTests(tester: self)

        let end = {
            TestFormat.printTestEnd()
            nextTest()
        }
        let getSpaceUsage = {
            tester.getSpaceUsage(end)
        }
        let getCurrentAccount = {
            tester.getCurrentAccount(getSpaceUsage)
        }
        let getAccountBatch = {
            tester.getAccountBatch(getCurrentAccount)
        }
        let getAccount = {
            tester.getAccount(getAccountBatch)
        }
        let start = {
            getAccount()
        }

        TestFormat.printTestBegin(#function)
        start()
    }

    func testAuthActions(_ nextTest: @escaping (() -> Void)) {
        let tester = AuthTests(tester: self)

        let end = {
            TestFormat.printTestEnd()
            nextTest()
        }
        let tokenRevoke = {
            tester.tokenRevoke(end)
        }
        let start = {
            tokenRevoke()
        }

        TestFormat.printTestBegin(#function)
        start()
    }
}

open class DropboxTeamTester {
    let team = DropboxClientsManager.authorizedTeamClient!.team!

    // Test business app with 'Team member file access' permission
    func testTeamMemberFileAcessActions(_ nextTest: (() -> Void)? = nil) {
        let end = {
            if let nextTest = nextTest {
                nextTest()
            } else {
                TestFormat.printAllTestsEnd()
            }
        }
        let testPerformActionAsMember = {
            DropboxTester().testAllUserEndpoints(true, nextTest: end)
        }
        let start = {
            self.testTeamMemberFileAcessActionsGroup(testPerformActionAsMember)
        }

        start()
    }

    // Test business app with 'Team member management' permission
    func testTeamMemberManagementActions(_ nextTest: (() -> Void)? = nil) {
        let end = {
            if let nextTest = nextTest {
                nextTest()
            } else {
                TestFormat.printAllTestsEnd()
            }
        }
        let start = {
            self.testTeamMemberManagementActionsGroup(end)
        }

        start()
    }

    func testTeamMemberFileAcessActionsGroup(_ nextTest: @escaping (() -> Void)) {
        let tester = TeamTests(tester: self)

        let end = {
            TestFormat.printTestEnd()
            nextTest()
        }
        let reportsGetStorage = {
            tester.reportsGetStorage(end)
        }
        let reportsGetMembership = {
            tester.reportsGetMembership(reportsGetStorage)
        }
        let reportsGetDevices = {
            tester.reportsGetDevices(reportsGetMembership)
        }
        let reportsGetActivity = {
            tester.reportsGetActivity(reportsGetDevices)
        }
        let linkedAppsListMembersLinkedApps = {
            tester.linkedAppsListMembersLinkedApps(reportsGetActivity)
        }
        let linkedAppsListMemberLinkedApps = {
            tester.linkedAppsListMemberLinkedApps(linkedAppsListMembersLinkedApps)
        }
        let getInfo = {
            tester.getInfo(linkedAppsListMemberLinkedApps)
        }
        let listMembersDevices = {
            tester.listMembersDevices(getInfo)
        }
        let listMemberDevices = {
            tester.listMemberDevices(listMembersDevices)
        }
        let initMembersGetInfo = {
            tester.initMembersGetInfo(listMemberDevices)
        }
        let start = {
            initMembersGetInfo()
        }

        TestFormat.printTestBegin(#function)
        start()
    }

    func testTeamMemberManagementActionsGroup(_ nextTest: @escaping (() -> Void)) {
        let tester = TeamTests(tester: self)

        let end = {
            TestFormat.printTestEnd()
            nextTest()
        }
        let membersRemove = {
            tester.membersRemove(end)
        }
        let membersSetProfile = {
            tester.membersSetProfile(membersRemove)
        }
        let membersSetAdminPermissions = {
            tester.membersSetAdminPermissions(membersSetProfile)
        }
        let membersSendWelcomeEmail = {
            tester.membersSendWelcomeEmail(membersSetAdminPermissions)
        }
        let membersList = {
            tester.membersList(membersSendWelcomeEmail)
        }
        let membersGetInfo = {
            tester.membersGetInfo(membersList)
        }
        let membersAdd = {
            tester.membersAdd(membersGetInfo)
        }
        let groupsDelete = {
            tester.groupsDelete(membersAdd)
        }
        let groupsUpdate = {
            tester.groupsUpdate(groupsDelete)
        }
        let groupsMembersList = {
            tester.groupsMembersList(groupsUpdate)
        }
        let groupsMembersAdd = {
            tester.groupsMembersAdd(groupsMembersList)
        }
        let groupsList = {
            tester.groupsList(groupsMembersAdd)
        }
        let groupsGetInfo = {
            tester.groupsGetInfo(groupsList)
        }
        let groupsCreate = {
            tester.groupsCreate(groupsGetInfo)
        }
        let initMembersGetInfo = {
            tester.initMembersGetInfo(groupsCreate)
        }
        let start = {
            initMembersGetInfo()
        }

        TestFormat.printTestBegin(#function)
        start()
    }
}


/**
    Dropbox User API Endpoint Tests
 */


open class AuthTests {
    let tester: DropboxTester

    public init(tester: DropboxTester) {
        self.tester = tester
    }

    func tokenRevoke(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.auth.tokenRevoke().response { response, error in
            if let _ = response {
                TestFormat.printOffset("Token successfully revoked")
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                print(callError)
            }
        }
    }
}

open class FilesTests {
    let tester: DropboxTester

    public init(tester: DropboxTester) {
        self.tester = tester
    }

    func deleteV2(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.deleteV2(path: TestData.baseFolder).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                print(callError)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            }
        }
    }

    func createFolderV2(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.createFolderV2(path: TestData.testFolderPath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func listFolder(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.listFolder(path: TestData.testFolderPath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func uploadData(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.upload(path: TestData.testFilePath, input: TestData.fileData).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func uploadDataSession(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)

        let uploadSessionAppendV2: ((String, Files.UploadSessionCursor) -> Void) = { sessionId, cursor in
            self.tester.files.uploadSessionAppendV2(cursor: cursor, input: TestData.fileData).response { response, error in
                if let _ = response {
                    let cursor = Files.UploadSessionCursor(sessionId: sessionId, offset: UInt64(TestData.fileData.count * 2))
                    let commitInfo = Files.CommitInfo(path: TestData.testFilePath + "_session")
                    self.tester.files.uploadSessionFinish(cursor: cursor, commit: commitInfo, input: TestData.fileData).response { response, error in
                        if let result = response {
                            print(result)
                            TestFormat.printOffset("Upload session complete")
                            TestFormat.printSubTestEnd(#function)
                            nextTest()
                        } else if let callError = error {
                            TestFormat.abort(String(describing: callError))
                        }
                    }
                } else if let callError = error {
                    TestFormat.abort(String(describing: callError))
                }
            }
        }

        self.tester.files.uploadSessionStart(input: TestData.fileData).response { response, error in
            if let result = response {
                let sessionId = result.sessionId
                print(result)
                TestFormat.printOffset("Acquiring sessionId")
                let cursor = Files.UploadSessionCursor(sessionId: sessionId, offset: UInt64(TestData.fileData.count))
                uploadSessionAppendV2(sessionId, cursor)
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func copyV2(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let copyOutputPath = TestData.testFilePath + "_duplicate" + "_" + TestData.testId
        tester.files.copyV2(fromPath: TestData.testFilePath, toPath: copyOutputPath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func copyReferenceGet(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.copyReferenceGet(path: TestData.testFilePath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func getMetadata(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.getMetadata(path: TestData.testFilePath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func getMetadataInvalid(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.getMetadata(path: "/").response { response, error in
            assert(error != nil, "This call should have errored!")
            TestFormat.printOffset("Error properly detected")
            TestFormat.printSubTestEnd(#function)
            nextTest()
        }
    }

    func getTemporaryLink(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.getTemporaryLink(path: TestData.testFilePath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func listRevisions(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.listRevisions(path: TestData.testFilePath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func move(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.createFolderV2(path: TestData.testFolderPath + "/" + "movedLocation").response { response, error in
            if let result = response {
                print(result)
                TestFormat.printOffset("Created destination folder")

                self.tester.files.moveV2(fromPath: TestData.testFolderPath, toPath: TestData.testFolderPath + "/" + "movedLocation").response { response, error in
                    if let result = response {
                        print(result)
                        TestFormat.printSubTestEnd(#function)
                        nextTest()
                    } else if let callError = error {
                        TestFormat.abort(String(describing: callError))
                    }
                }
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func saveUrl(_ nextTest: @escaping (() -> Void), asMember: Bool = false) {
        if asMember {
            nextTest()
            return
        }

        TestFormat.printSubTestBegin(#function)
        tester.files.saveUrl(path: TestData.testFolderPath + "/" + "dbx-test.html", url: "https://www.google.com").response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func downloadToFile(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.download(path: TestData.testFilePath, overwrite: true, destination: TestData.destination).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func downloadAgain(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.download(path: TestData.testFilePath, overwrite: true, destination: TestData.destination).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func downloadError(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.download(path: TestData.testFilePath + "_does_not_exist", overwrite: false, destination: TestData.destinationException).response { response, error in
            assert(error != nil, "This call should have errored!")
            assert(!FileManager.default.fileExists(atPath: TestData.destURLException.path))
            TestFormat.printOffset("Error properly detected")
            TestFormat.printSubTestEnd(#function)
            nextTest()
        }
    }

    func downloadToMemory(_ nextTest: @escaping (() -> Void)) {
        
        tester.files.download(path: "/test/path/in/Dropbox/account")
            .response { response, error in
                if let response = response {
                    let responseMetadata = response.0
                    print(responseMetadata)
                    let fileContents = response.1
                    print(fileContents)
                } else if let error = error {
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
        }
        
        TestFormat.printSubTestBegin(#function)
        tester.files.download(path: TestData.testFilePath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func uploadFile(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.upload(path: TestData.testFilePath + "_from_file", input: TestData.destURL).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func listFolderLongpollAndTrigger(_ nextTest: @escaping (() -> Void), asMember: Bool = false) {
        if asMember {
            nextTest()
            return
        }

        let copy = {
            TestFormat.printOffset("Making change that longpoll will detect (copy file)")
            let copyOutputPath = TestData.testFilePath + "_duplicate2" + "_" + TestData.testId
            self.tester.files.copyV2(fromPath: TestData.testFilePath, toPath: copyOutputPath).response { response, error in
                if let result = response {
                    print(result)
                } else if let callError = error {
                    TestFormat.abort(String(describing: callError))
                }
            }
        }

        let listFolderContinue: ((String) -> Void) = { cursor in
            self.tester.files.listFolderContinue(cursor: cursor).response { response, error in
                if let result = response {
                    TestFormat.printOffset("Here are the changes:")
                    print(result)
                    TestFormat.printSubTestEnd(#function)
                    nextTest()
                } else if let callError = error {
                    TestFormat.abort(String(describing: callError))
                }
            }
        }

        let listFolderLongpoll: ((String) -> Void) = { cursor in
            TestFormat.printOffset("Establishing longpoll")
            self.tester.files.listFolderLongpoll(cursor: cursor).response { response, error in
                if let result = response {
                    print(result)
                    if (result.changes) {
                        TestFormat.printOffset("Changes found")
                        listFolderContinue(cursor)
                    } else {
                        TestFormat.abort("Improperly set up changes trigger")
                    }
                } else if let callError = error {
                    TestFormat.abort(String(describing: callError))
                }
            }
            copy()
        }

        TestFormat.printSubTestBegin(#function)

        TestFormat.printOffset("Acquiring cursor")
        tester.files.listFolderGetLatestCursor(path: TestData.testFolderPath).response { response, error in
            if let result = response {
                TestFormat.printOffset("Cursor acquired")
                print(result)
                let cursor = result.cursor

                listFolderLongpoll(cursor)
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }
}

open class SharingTests {
    let tester: DropboxTester
    var sharedFolderId = "placeholder"
    var sharedLink = "placeholder"

    public init(tester: DropboxTester) {
        self.tester = tester
    }

    func shareFolder(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.shareFolder(path: TestData.testShareFolderPath).response { response, error in
            if let result = response {
                switch result {
                case .asyncJobId(let asyncJobId):
                    TestFormat.printOffset("Folder not yet shared! Job id: \(asyncJobId). Please adjust test order.")
                case .complete(let sharedFolderMetadata):
                    print(sharedFolderMetadata)
                    self.sharedFolderId = sharedFolderMetadata.sharedFolderId
                    TestFormat.printSubTestEnd(#function)
                    nextTest()
                }
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func createSharedLinkWithSettings(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.createSharedLinkWithSettings(path: TestData.testShareFolderPath).response { response, error in
            if let result = response {
                print(result)
                self.sharedLink = result.url
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func getFolderMetadata(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.getFolderMetadata(sharedFolderId: sharedFolderId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func getSharedLinkMetadata(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.getSharedLinkMetadata(url: sharedLink).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func addFolderMember(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)

        let memberSelector = Sharing.MemberSelector.email(TestData.accountId3Email)
        let addFolderMemberArg = Sharing.AddMember(member: memberSelector)
        tester.sharing.addFolderMember(sharedFolderId: sharedFolderId, members: [addFolderMemberArg], quiet: true).response { response, error in
            if let _ = response {
                TestFormat.printOffset("Folder member added")
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func listFolderMembers(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.listFolderMembers(sharedFolderId: sharedFolderId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func listFolders(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.listFolders(limit: 2).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func listSharedLinks(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.listSharedLinks().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func removeFolderMember(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)

        let memberSelector = Sharing.MemberSelector.dropboxId(TestData.accountId3)

        let checkJobStatus: ((String) -> Void) = { asyncJobId in
            self.tester.sharing.checkJobStatus(asyncJobId: asyncJobId).response { response, error in
                if let result = response {
                    print(result)
                    switch result {
                    case .inProgress:
                        TestFormat.printOffset("Folder member not yet removed! Job id: \(asyncJobId). Please adjust test order.")
                    case .complete:
                        TestFormat.printSubTestEnd(#function)
                        nextTest()
                    case .failed(let jobError):
                        TestFormat.abort(String(describing: jobError))
                    }
                } else if let callError = error {
                    TestFormat.abort(String(describing: callError))
                }
            }
        }

        tester.sharing.removeFolderMember(sharedFolderId: sharedFolderId, member: memberSelector, leaveACopy: false).response { response, error in
            if let result = response {
                print(result)

                switch result {
                case .asyncJobId(let asyncJobId):
                    TestFormat.printOffset("Folder member not yet removed! Job id: \(asyncJobId)")
                    print("Sleeping for 3 seconds, then trying again", terminator: "")
                    for _ in 1...3 {
                        sleep(1)
                        print(".", terminator:"")
                    }
                    print()
                    TestFormat.printOffset("Retrying!")
                    checkJobStatus(asyncJobId)
                }
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func revokeSharedLink(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.revokeSharedLink(url: sharedLink).response { response, error in
            if let _ = response {
                TestFormat.printOffset("Shared link revoked")
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func unmountFolder(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.unmountFolder(sharedFolderId: sharedFolderId).response { response, error in
            if let _ = response {
                TestFormat.printOffset("Folder unmounted")
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func mountFolder(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.mountFolder(sharedFolderId: sharedFolderId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func updateFolderPolicy(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.updateFolderPolicy(sharedFolderId: sharedFolderId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func unshareFolder(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.unshareFolder(sharedFolderId: sharedFolderId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }
}

open class UserTests {
    let tester: DropboxTester

    public init(tester: DropboxTester) {
        self.tester = tester
    }

    func getAccount(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.users.getAccount(accountId: TestData.accountId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func getAccountBatch(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let accountIds = [TestData.accountId, TestData.accountId2]
        tester.users.getAccountBatch(accountIds: accountIds).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func getCurrentAccount(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.users.getCurrentAccount().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func getSpaceUsage(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.users.getSpaceUsage().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }
}


/**
    Dropbox Team API Endpoint Tests
 */


open class TeamTests {
    let tester: DropboxTeamTester
    var teamMemberId: String?
    var teamMemberId2: String?
    public init(tester: DropboxTeamTester) {
        self.tester = tester
    }


    /**
        Permission: Team member file access
    */

    func initMembersGetInfo(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let userSelectArg = Team.UserSelectorArg.email(TestData.teamMemberEmail)
        tester.team.membersGetInfo(members: [userSelectArg]).response { response, error in
            if let result = response {
                print(result)
                switch result[0] {
                case .idNotFound:
                    TestFormat.abort("Tester email improperly set up")
                case .memberInfo(let memberInfo):
                    self.teamMemberId = memberInfo.profile.teamMemberId
                    DropboxClientsManager.authorizedClient = DropboxClientsManager.authorizedTeamClient!.asMember(self.teamMemberId!)
                }
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func listMemberDevices(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.devicesListMemberDevices(teamMemberId: self.teamMemberId!).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func listMembersDevices(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.devicesListMembersDevices().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func linkedAppsListMemberLinkedApps(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.linkedAppsListMemberLinkedApps(teamMemberId: self.teamMemberId!).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func linkedAppsListMembersLinkedApps(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.linkedAppsListMembersLinkedApps().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func getInfo(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.getInfo().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func reportsGetActivity(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let calendar = Calendar.current
        let twoDaysAgo = (calendar as NSCalendar).date(byAdding: .day, value: -2, to: Date(), options: [])
        tester.team.reportsGetActivity(startDate: twoDaysAgo, endDate: Date()).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func reportsGetDevices(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let calendar = Calendar.current
        let twoDaysAgo = (calendar as NSCalendar).date(byAdding: .day, value: -2, to: Date(), options: [])
        tester.team.reportsGetDevices(startDate: twoDaysAgo, endDate: Date()).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func reportsGetMembership(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let calendar = Calendar.current
        let twoDaysAgo = (calendar as NSCalendar).date(byAdding: .day, value: -2, to: Date(), options: [])
        tester.team.reportsGetMembership(startDate: twoDaysAgo, endDate: Date()).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func reportsGetStorage(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let calendar = Calendar.current
        let twoDaysAgo = (calendar as NSCalendar).date(byAdding: .day, value: -2, to: Date(), options: [])
        tester.team.reportsGetStorage(startDate: twoDaysAgo, endDate: Date()).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }


    /**
        Permission: Team member management
    */


    func groupsCreate(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.groupsCreate(groupName: TestData.groupName, groupExternalId: TestData.groupExternalId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func groupsGetInfo(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let groupsSelector = Team.GroupsSelector.groupExternalIds([TestData.groupExternalId])
        tester.team.groupsGetInfo(groupsSelector: groupsSelector).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func groupsList(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.groupsList().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func groupsMembersAdd(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let groupSelector = Team.GroupSelector.groupExternalId(TestData.groupExternalId)

        let userSelectorArg = Team.UserSelectorArg.teamMemberId(self.teamMemberId!)
        let accessType = Team.GroupAccessType.member
        let memberAccess = Team.MemberAccess(user: userSelectorArg, accessType: accessType)
        let members = [memberAccess]

        tester.team.groupsMembersAdd(group: groupSelector, members: members).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func groupsMembersList(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let groupSelector = Team.GroupSelector.groupExternalId(TestData.groupExternalId)

        tester.team.groupsMembersList(group: groupSelector).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func groupsUpdate(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let groupSelector = Team.GroupSelector.groupExternalId(TestData.groupExternalId)

        tester.team.groupsUpdate(group: groupSelector, newGroupName: "New Group Name").response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func groupsDelete(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)

        let jobStatus: ((String) -> Void) = { jobId in
            self.tester.team.groupsJobStatusGet(asyncJobId: jobId).response { response, error in
                if let result = response {
                    print(result)
                    switch result {
                    case .inProgress:
                        TestFormat.abort("Took too long to delete")
                    case .complete:
                        TestFormat.printOffset("Deleted")
                        TestFormat.printSubTestEnd(#function)
                        nextTest()
                    }
                } else if let callError = error {
                    TestFormat.abort(String(describing: callError))
                }
            }
        }

        let groupsSelector = Team.GroupSelector.groupExternalId(TestData.groupExternalId)
        self.tester.team.groupsDelete(groupSelector: groupsSelector).response { response, error in
            if let result = response {
                print(result)
                switch result {
                case .asyncJobId(let asyncJobId):
                    TestFormat.printOffset("Waiting for deletion...")
                    sleep(1)
                    jobStatus(asyncJobId)
                case .complete:
                    TestFormat.printOffset("Deleted")
                    TestFormat.printSubTestEnd(#function)
                    nextTest()
                }
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func membersAdd(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        
        let jobStatus: ((String) -> Void) = { jobId in
            self.tester.team.membersAddJobStatusGet(asyncJobId: jobId).response { response, error in
                if let result = response {
                    print(result)
                    switch result {
                    case .inProgress:
                        TestFormat.abort("Took too long to add")
                    case .complete(let memberAddResult):
                        switch memberAddResult[0] {
                        case .success(let teamMemberInfo):
                            let teamMemberId = teamMemberInfo.profile.teamMemberId
                            self.teamMemberId2 = teamMemberId
                        default:
                            TestFormat.abort("Member add finished but did not go as expected:\n \(memberAddResult)")
                        }
                        TestFormat.printOffset("Member added")
                        TestFormat.printSubTestEnd(#function)
                        nextTest()
                    case.failed(let message):
                        TestFormat.abort(message)
                    }
                } else if let callError = error {
                    TestFormat.abort(String(describing: callError))
                }
            }
        }

        let memberAddArg = Team.MemberAddArg(memberEmail: TestData.newMemberEmail, memberGivenName: "FirstName", memberSurname: "LastName")
        tester.team.membersAdd(newMembers: [memberAddArg]).response { response, error in
            if let result = response {
                print(result)
                switch result {
                case .asyncJobId(let asyncJobId):
                    TestFormat.printOffset("Result incomplete...")
                    jobStatus(asyncJobId)
                case .complete(let memberAddResult):
                    switch memberAddResult[0] {
                    case .success(let teamMemberInfo):
                        let teamMemberId = teamMemberInfo.profile.teamMemberId
                        self.teamMemberId2 = teamMemberId
                    default:
                        TestFormat.abort("Member add finished but did not go as expected:\n \(memberAddResult)")
                    }
                    TestFormat.printOffset("Member added")
                    TestFormat.printSubTestEnd(#function)
                    nextTest()
                }
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func membersGetInfo(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let userSelectArg = Team.UserSelectorArg.teamMemberId(self.teamMemberId!)
        tester.team.membersGetInfo(members: [userSelectArg]).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func membersList(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.membersList(limit: 2).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func membersSendWelcomeEmail(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let userSelectorArg = Team.UserSelectorArg.teamMemberId(self.teamMemberId!)
        tester.team.membersSendWelcomeEmail(userSelectorArg: userSelectorArg).response { response, error in
            if let _ = response {
                TestFormat.printOffset("Welcome email sent!")
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func membersSetAdminPermissions(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let userSelectorArg = Team.UserSelectorArg.teamMemberId(self.teamMemberId2!)
        let newRole = Team.AdminTier.teamAdmin
        tester.team.membersSetAdminPermissions(user: userSelectorArg, newRole: newRole).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func membersSetProfile(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let userSelectorArg = Team.UserSelectorArg.teamMemberId(self.teamMemberId2!)
        tester.team.membersSetProfile(user: userSelectorArg, newGivenName: "NewFirstName").response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }

    func membersRemove(_ nextTest: @escaping (() -> Void)) {
        TestFormat.printSubTestBegin(#function)

        let jobStatus: ((String) -> Void) = { jobId in
            self.tester.team.membersRemoveJobStatusGet(asyncJobId: jobId).response { response, error in
                if let result = response {
                    print(result)
                    switch result {
                    case .inProgress:
                        TestFormat.abort("Took too long to remove")
                    case .complete:
                        TestFormat.printOffset("Member removed")
                        TestFormat.printSubTestEnd(#function)
                        nextTest()
                    }
                } else if let callError = error {
                    TestFormat.abort(String(describing: callError))
                }
            }
        }

        let userSelectorArg = Team.UserSelectorArg.teamMemberId(self.teamMemberId2!)
        tester.team.membersRemove(user: userSelectorArg).response { response, error in
            if let result = response {
                print(result)
                switch result {
                case .asyncJobId(let asyncJobId):
                    TestFormat.printOffset("Result incomplete...")
                    jobStatus(asyncJobId)
                case .complete:
                    TestFormat.printOffset("Member removed")
                    TestFormat.printSubTestEnd(#function)
                    nextTest()
                }
            } else if let callError = error {
                TestFormat.abort(String(describing: callError))
            }
        }
    }
}

open class TestFormat {
    static let smallDividerSize = 150
    static let largeDividerSize = 200

    class func abort(_ error: String) {
        print("ERROR: \(error)")
        print("Terminating....")

        exit(0)
    }

    class func printTestBegin(_ title: String) {
        printLargeDivider()
        printTitle(title)
        printLargeDivider()
        printOffset("Beginning.....")
    }

    class func printTestEnd() {
        printOffset("Test Group Completed")
        printLargeDivider()
    }

    class func printAllTestsEnd() {
        printLargeDivider()
        printOffset("ALL TESTS COMPLETED")
        printLargeDivider()
    }

    class func printSubTestBegin(_ title: String) {
        printSmallDivider()
        printTitle(title)
        print("")
    }

    class func printSubTestEnd(_ result: String) {
        print("")
        printTitle(result)
    }

    class func printTitle(_ title: String) {
        print("     \(title)")
    }

    class func printOffset(_ str: String) {
        print("")
        print("     *  \(str)  *")
        print("")
    }

    class func printSmallDivider() {
        var result = ""
        for _ in 1...smallDividerSize {
            result += "-"
        }
        print(result)
    }

    class func printLargeDivider() {
        var result = ""
        for _ in 1...largeDividerSize {
            result += "-"
        }
        print(result)
    }
}
