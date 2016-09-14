import Foundation
import SwiftyDropbox

public class DropboxTester {
    let auth = Dropbox.authorizedClient!.auth
    let users = Dropbox.authorizedClient!.users
    let files = Dropbox.authorizedClient!.files
    let sharing = Dropbox.authorizedClient!.sharing
}

public class DropboxTeamTester {
    let team = Dropbox.authorizedTeamClient!.team
}


/**
    Dropbox User API Endpoint Tests
 */


public class AuthTests {
    let tester: DropboxTester

    public init(tester: DropboxTester) {
        self.tester = tester
    }

    func tokenRevoke(nextTest: (() -> Void)) {
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

public class FilesTests {
    let tester: DropboxTester

    public init(tester: DropboxTester) {
        self.tester = tester
    }

    func delete(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.delete(path: TestData.baseFolder).response { response, error in
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

    func createFolder(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.createFolder(path: TestData.testFolderPath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func listFolder(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.listFolder(path: TestData.testFolderPath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func uploadData(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.upload(path: TestData.testFilePath, input: TestData.fileData).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func uploadDataSession(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)

        let uploadSessionAppendV2: ((String, Files.UploadSessionCursor) -> Void) = { sessionId, cursor in
            self.tester.files.uploadSessionAppendV2(cursor: cursor, input: TestData.fileData).response { response, error in
                if let _ = response {
                    let cursor = Files.UploadSessionCursor(sessionId: sessionId, offset: UInt64(TestData.fileData.length * 2))
                    let commitInfo = Files.CommitInfo(path: TestData.testFilePath + "_session")
                    self.tester.files.uploadSessionFinish(cursor: cursor, commit: commitInfo, input: TestData.fileData).response { response, error in
                        if let result = response {
                            print(result)
                            TestFormat.printOffset("Upload session complete")
                            TestFormat.printSubTestEnd(#function)
                            nextTest()
                        } else if let callError = error {
                            TestFormat.abort(String(callError))
                        }
                    }
                } else if let callError = error {
                    TestFormat.abort(String(callError))
                }
            }
        }

        tester.files.uploadSessionStart(input: TestData.fileData).response { response, error in
            if let result = response {
                let sessionId = result.sessionId
                print(result)
                TestFormat.printOffset("Acquiring sessionId")
                let cursor = Files.UploadSessionCursor(sessionId: sessionId, offset: UInt64(TestData.fileData.length))
                uploadSessionAppendV2(sessionId, cursor)
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func copy(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let copyOutputPath = TestData.testFilePath + "_duplicate" + "_" + TestData.testId
        tester.files.copy(fromPath: TestData.testFilePath, toPath: copyOutputPath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func copyReferenceGet(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.copyReferenceGet(path: TestData.testFilePath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func getMetadata(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.getMetadata(path: TestData.testFilePath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func getMetadataInvalid(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.getMetadata(path: "/").response { response, error in
            assert(error != nil, "This call should have errored!")
            TestFormat.printOffset("Error properly detected")
            TestFormat.printSubTestEnd(#function)
            nextTest()
        }
    }

    func getTemporaryLink(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.getTemporaryLink(path: TestData.testFilePath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func listRevisions(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.listRevisions(path: TestData.testFilePath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func move(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.createFolder(path: TestData.testFolderPath + "/" + "movedLocation").response { response, error in
            if let result = response {
                print(result)
                TestFormat.printOffset("Created destination folder")

                self.tester.files.move(fromPath: TestData.testFolderPath, toPath: TestData.testFolderPath + "/" + "movedLocation").response { response, error in
                    if let result = response {
                        print(result)
                        TestFormat.printSubTestEnd(#function)
                        nextTest()
                    } else if let callError = error {
                        TestFormat.abort(String(callError))
                    }
                }
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }
 
    func saveUrl(nextTest: (() -> Void), asMember: Bool = false) {
        if asMember {
            nextTest()
            return
        }

        TestFormat.printSubTestBegin(#function)
        tester.files.saveUrl(path: TestData.testFolderPath + "/" + "dbx-test.html", url: "https://www.dropbox.com/help/5").response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func downloadToFile(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.download(path: TestData.testFilePath, overwrite: true, destination: TestData.destination).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func downloadAgain(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.download(path: TestData.testFilePath, overwrite: true, destination: TestData.destination).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func downloadError(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.download(path: TestData.testFilePath + "_does_not_exist", overwrite: false, destination: TestData.destinationException).response { response, error in
            assert(error != nil, "This call should have errored!")
            assert(!NSFileManager.defaultManager().fileExistsAtPath(TestData.destURLException!.path!))
            TestFormat.printOffset("Error properly detected")
            TestFormat.printSubTestEnd(#function)
            nextTest()
        }
    }

    func downloadToMemory(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.download(path: TestData.testFilePath).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func uploadFile(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.files.upload(path: TestData.testFilePath + "_from_file", input: TestData.destURL!).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func listFolderLongpollAndTrigger(nextTest: (() -> Void), asMember: Bool = false) {
        if asMember {
            nextTest()
            return
        }

        let copy = {
            TestFormat.printOffset("Making change that longpoll will detect (copy file)")
            let copyOutputPath = TestData.testFilePath + "_duplicate2" + "_" + TestData.testId
            self.tester.files.copy(fromPath: TestData.testFilePath, toPath: copyOutputPath).response { response, error in
                if let result = response {
                    print(result)
                } else if let callError = error {
                    TestFormat.abort(String(callError))
                }
            }
        }

        let listFolderContinue: (String -> Void) = { cursor in
            self.tester.files.listFolderContinue(cursor: cursor).response { response, error in
                if let result = response {
                    TestFormat.printOffset("Here are the changes:")
                    print(result)
                    TestFormat.printSubTestEnd(#function)
                    nextTest()
                } else if let callError = error {
                    TestFormat.abort(String(callError))
                }
            }
        }

        let listFolderLongpoll: (String -> Void) = { cursor in
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
                    TestFormat.abort(String(callError))
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
                TestFormat.abort(String(callError))
            }
        }
    }
}

public class SharingTests {
    let tester: DropboxTester
    var sharedFolderId = "placeholder"
    var sharedLink = "placeholder"

    public init(tester: DropboxTester) {
        self.tester = tester
    }

    func shareFolder(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.shareFolder(path: TestData.testShareFolderPath).response { response, error in
            if let result = response {
                switch result {
                case .AsyncJobId(let asyncJobId):
                    TestFormat.printOffset("Folder not yet shared! Job id: \(asyncJobId). Please adjust test order.")
                case .Complete(let sharedFolderMetadata):
                    print(sharedFolderMetadata)
                    self.sharedFolderId = sharedFolderMetadata.sharedFolderId
                    TestFormat.printSubTestEnd(#function)
                    nextTest()
                }
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func createSharedLinkWithSettings(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.createSharedLinkWithSettings(path: TestData.testShareFolderPath).response { response, error in
            if let result = response {
                print(result)
                self.sharedLink = result.url
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func getFolderMetadata(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.getFolderMetadata(sharedFolderId: sharedFolderId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func getSharedLinkMetadata(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.getSharedLinkMetadata(url: sharedLink).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func addFolderMember(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)

        let memberSelector = Sharing.MemberSelector.Email(TestData.accountId3Email)
        let addFolderMemberArg = Sharing.AddMember(member: memberSelector)
        tester.sharing.addFolderMember(sharedFolderId: sharedFolderId, members: [addFolderMemberArg], quiet: true).response { response, error in
            if let _ = response {
                TestFormat.printOffset("Folder memeber added")
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func listFolderMembers(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.listFolderMembers(sharedFolderId: sharedFolderId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func listFolders(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.listFolders(2).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func listSharedLinks(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.listSharedLinks().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func removeFolderMember(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)

        let memberSelector = Sharing.MemberSelector.DropboxId(TestData.accountId3)

        let checkJobStatus: (String -> Void) = { asyncJobId in
            self.tester.sharing.checkJobStatus(asyncJobId: asyncJobId).response { response, error in
                if let result = response {
                    print(result)
                    switch result {
                    case .InProgress:
                        TestFormat.printOffset("Folder member not yet removed! Job id: \(asyncJobId). Please adjust test order.")
                    case .Complete:
                        TestFormat.printSubTestEnd(#function)
                        nextTest()
                    case .Failed(let jobError):
                        TestFormat.abort(String(jobError))
                    }
                } else if let callError = error {
                    TestFormat.abort(String(callError))
                }
            }
        }

        tester.sharing.removeFolderMember(sharedFolderId: sharedFolderId, member: memberSelector, leaveACopy: false).response { response, error in
            if let result = response {
                print(result)

                switch result {
                case .AsyncJobId(let asyncJobId):
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
                TestFormat.abort(String(callError))
            }
        }
    }

    func revokeSharedLink(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.revokeSharedLink(url: sharedLink).response { response, error in
            if let _ = response {
                TestFormat.printOffset("Shared link revoked")
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func unmountFolder(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.unmountFolder(sharedFolderId: sharedFolderId).response { response, error in
            if let _ = response {
                TestFormat.printOffset("Folder unmounted")
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func mountFolder(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.mountFolder(sharedFolderId: sharedFolderId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func updateFolderPolicy(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.updateFolderPolicy(sharedFolderId: sharedFolderId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func unshareFolder(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.sharing.unshareFolder(sharedFolderId: sharedFolderId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }
}

public class UserTests {
    let tester: DropboxTester

    public init(tester: DropboxTester) {
        self.tester = tester
    }

    func getAccount(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.users.getAccount(accountId: TestData.accountId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func getAccountBatch(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let accountIds = [TestData.accountId, TestData.accountId2]
        tester.users.getAccountBatch(accountIds: accountIds).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func getCurrentAccount(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.users.getCurrentAccount().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func getSpaceUsage(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.users.getSpaceUsage().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }
}


/**
    Dropbox Team API Endpoint Tests
 */


public class TeamTests {
    let tester: DropboxTeamTester
    var teamMemberId: String?
    var teamMemberId2: String?
    public init(tester: DropboxTeamTester) {
        self.tester = tester
    }


    /**
        Permission: Team member file access
    */

    func initMembersGetInfo(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let userSelectArg = Team.UserSelectorArg.Email(TestTeamData.teamMemberEmail)
        tester.team.membersGetInfo(members: [userSelectArg]).response { response, error in
            if let result = response {
                print(result)
                switch result[0] {
                case .IdNotFound:
                    TestFormat.abort("Tester email improperly set up")
                case .MemberInfo(let memberInfo):
                    self.teamMemberId = memberInfo.profile.teamMemberId
                    Dropbox.authorizedClient = Dropbox.authorizedTeamClient!.asMember(self.teamMemberId!)
                }
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func listMemberDevices(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.devicesListMemberDevices(teamMemberId: self.teamMemberId!).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func listMembersDevices(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.devicesListMembersDevices().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func linkedAppsListMemberLinkedApps(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.linkedAppsListMemberLinkedApps(teamMemberId: self.teamMemberId!).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func linkedAppsListMembersLinkedApps(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.linkedAppsListMembersLinkedApps().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func getInfo(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.getInfo().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func reportsGetActivity(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let calendar = NSCalendar.currentCalendar()
        let twoDaysAgo = calendar.dateByAddingUnit(.Day, value: -2, toDate: NSDate(), options: [])
        tester.team.reportsGetActivity(twoDaysAgo, endDate: NSDate()).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func reportsGetDevices(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let calendar = NSCalendar.currentCalendar()
        let twoDaysAgo = calendar.dateByAddingUnit(.Day, value: -2, toDate: NSDate(), options: [])
        tester.team.reportsGetDevices(twoDaysAgo, endDate: NSDate()).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func reportsGetMembership(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let calendar = NSCalendar.currentCalendar()
        let twoDaysAgo = calendar.dateByAddingUnit(.Day, value: -2, toDate: NSDate(), options: [])
        tester.team.reportsGetMembership(twoDaysAgo, endDate: NSDate()).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func reportsGetStorage(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let calendar = NSCalendar.currentCalendar()
        let twoDaysAgo = calendar.dateByAddingUnit(.Day, value: -2, toDate: NSDate(), options: [])
        tester.team.reportsGetStorage(twoDaysAgo, endDate: NSDate()).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }


    /**
        Permission: Team member management
    */


    func groupsCreate(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.groupsCreate(groupName: TestTeamData.groupName, groupExternalId: TestTeamData.groupExternalId).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func groupsGetInfo(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let groupsSelector = Team.GroupsSelector.GroupExternalIds([TestTeamData.groupExternalId])
        tester.team.groupsGetInfo(groupsSelector: groupsSelector).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func groupsList(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.groupsList().response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func groupsMembersAdd(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let groupSelector = Team.GroupSelector.GroupExternalId(TestTeamData.groupExternalId)

        let userSelectorArg = Team.UserSelectorArg.TeamMemberId(self.teamMemberId!)
        let accessType = Team.GroupAccessType.Member
        let memberAccess = Team.MemberAccess(user: userSelectorArg, accessType: accessType)
        let members = [memberAccess]

        tester.team.groupsMembersAdd(group: groupSelector, members: members).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func groupsMembersList(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let groupSelector = Team.GroupSelector.GroupExternalId(TestTeamData.groupExternalId)

        tester.team.groupsMembersList(group: groupSelector).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func groupsUpdate(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let groupSelector = Team.GroupSelector.GroupExternalId(TestTeamData.groupExternalId)

        tester.team.groupsUpdate(group: groupSelector, newGroupName: "New Group Name").response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func groupsDelete(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)

        let jobStatus: (String -> Void) = { jobId in
            self.tester.team.groupsJobStatusGet(asyncJobId: jobId).response { response, error in
                if let result = response {
                    print(result)
                    switch result {
                    case .InProgress:
                        TestFormat.abort("Took too long to delete")
                    case .Complete:
                        TestFormat.printOffset("Deleted")
                        TestFormat.printSubTestEnd(#function)
                        nextTest()
                    }
                } else if let callError = error {
                    TestFormat.abort(String(callError))
                }
            }
        }

        let groupsSelector = Team.GroupSelector.GroupExternalId(TestTeamData.groupExternalId)
        self.tester.team.groupsDelete(groupSelector: groupsSelector).response { response, error in
            if let result = response {
                print(result)
                switch result {
                case .AsyncJobId(let asyncJobId):
                    TestFormat.printOffset("Waiting for deletion...")
                    jobStatus(asyncJobId)
                case .Complete:
                    TestFormat.printOffset("Deleted")
                    TestFormat.printSubTestEnd(#function)
                    nextTest()
                }
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func membersAdd(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        
        let jobStatus: (String -> Void) = { jobId in
            self.tester.team.membersAddJobStatusGet(asyncJobId: jobId).response { response, error in
                if let result = response {
                    print(result)
                    switch result {
                    case .InProgress:
                        TestFormat.abort("Took too long to add")
                    case .Complete(let memberAddResult):
                        switch memberAddResult[0] {
                        case .Success(let teamMemberInfo):
                            let teamMemberId = teamMemberInfo.profile.teamMemberId
                            self.teamMemberId2 = teamMemberId
                        default:
                            TestFormat.abort("Member add finished but did not go as expected:\n \(memberAddResult)")
                        }
                        TestFormat.printOffset("Member added")
                        TestFormat.printSubTestEnd(#function)
                        nextTest()
                    case.Failed(let message):
                        TestFormat.abort(message)
                    }
                } else if let callError = error {
                    TestFormat.abort(String(callError))
                }
            }
        }

        let memberAddArg = Team.MemberAddArg(memberEmail: TestTeamData.newMemberEmail, memberGivenName: "FirstName", memberSurname: "LastName")
        tester.team.membersAdd(newMembers: [memberAddArg]).response { response, error in
            if let result = response {
                print(result)
                switch result {
                case .AsyncJobId(let asyncJobId):
                    TestFormat.printOffset("Result incomplete...")
                    jobStatus(asyncJobId)
                case .Complete(let memberAddResult):
                    switch memberAddResult[0] {
                    case .Success(let teamMemberInfo):
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
                TestFormat.abort(String(callError))
            }
        }
    }

    func membersGetInfo(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let userSelectArg = Team.UserSelectorArg.TeamMemberId(self.teamMemberId!)
        tester.team.membersGetInfo(members: [userSelectArg]).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func membersList(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        tester.team.membersList(2).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func membersSendWelcomeEmail(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let userSelectorArg = Team.UserSelectorArg.TeamMemberId(self.teamMemberId!)
        tester.team.membersSendWelcomeEmail(userSelectorArg: userSelectorArg).response { response, error in
            if let _ = response {
                TestFormat.printOffset("Welcome email sent!")
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func membersSetAdminPermissions(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let userSelectorArg = Team.UserSelectorArg.TeamMemberId(self.teamMemberId2!)
        let newRole = Team.AdminTier.TeamAdmin
        tester.team.membersSetAdminPermissions(user: userSelectorArg, newRole: newRole).response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func membersSetProfile(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)
        let userSelectorArg = Team.UserSelectorArg.TeamMemberId(self.teamMemberId2!)
        tester.team.membersSetProfile(user: userSelectorArg, newGivenName: "NewFirstName").response { response, error in
            if let result = response {
                print(result)
                TestFormat.printSubTestEnd(#function)
                nextTest()
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }

    func membersRemove(nextTest: (() -> Void)) {
        TestFormat.printSubTestBegin(#function)

        let jobStatus: (String -> Void) = { jobId in
            self.tester.team.membersRemoveJobStatusGet(asyncJobId: jobId).response { response, error in
                if let result = response {
                    print(result)
                    switch result {
                    case .InProgress:
                        TestFormat.abort("Took too long to remove")
                    case .Complete:
                        TestFormat.printOffset("Member removed")
                        TestFormat.printSubTestEnd(#function)
                        nextTest()
                    }
                } else if let callError = error {
                    TestFormat.abort(String(callError))
                }
            }
        }

        let userSelectorArg = Team.UserSelectorArg.TeamMemberId(self.teamMemberId2!)
        tester.team.membersRemove(user: userSelectorArg).response { response, error in
            if let result = response {
                print(result)
                switch result {
                case .AsyncJobId(let asyncJobId):
                    TestFormat.printOffset("Result incomplete...")
                    jobStatus(asyncJobId)
                case .Complete:
                    TestFormat.printOffset("Member removed")
                    TestFormat.printSubTestEnd(#function)
                    nextTest()
                }
            } else if let callError = error {
                TestFormat.abort(String(callError))
            }
        }
    }
}

public class TestFormat {
    static let smallDividerSize = 150
    static let largeDividerSize = 200

    class func abort(error: String) {
        print("ERROR: \(error)")
        print("Terminating....")

        exit(0)
    }

    class func printTestBegin(title: String) {
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

    class func printSubTestBegin(title: String) {
        printSmallDivider()
        printTitle(title)
        print("")
    }

    class func printSubTestEnd(result: String) {
        print("")
        printTitle(result)
    }

    class func printTitle(title: String) {
        print("     \(title)")
    }

    class func printOffset(str: String) {
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
