import Cocoa
import SwiftyDropbox

class ViewController: NSViewController {
    @IBOutlet weak var oauthLinkButton: NSButton!
    @IBOutlet weak var oauthLinkBrowserButton: NSButton!
    @IBOutlet weak var oauthUnlinkButton: NSButton!
    @IBOutlet weak var runApiTestsButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
//        checkButtons()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func oauthLinkButtonPressed(sender: AnyObject) {
        if Dropbox.authorizedClient == nil && Dropbox.authorizedTeamClient == nil {
            Dropbox.authorizeFromController(NSWorkspace.sharedWorkspace(), controller: self, openURL: {(url: NSURL) -> Void in NSWorkspace.sharedWorkspace().openURL(url)})
        }
    }

    @IBAction func oauthLinkBrowserButtonPressed(sender: AnyObject) {
        Dropbox.unlinkClient()
        Dropbox.authorizeFromController(NSWorkspace.sharedWorkspace(), controller: self, openURL: {(url: NSURL) -> Void in NSWorkspace.sharedWorkspace().openURL(url)}, browserAuth: true)
    }

    @IBAction func oauthUnlinkButtonPressed(sender: AnyObject) {
        Dropbox.unlinkClient()
        checkButtons()
    }
    
    @IBAction func runApiTestsButtonPressed(sender: AnyObject) {
        if Dropbox.authorizedClient != nil || Dropbox.authorizedTeamClient != nil {
            let unlink = {
                Dropbox.unlinkClient()
                self.checkButtons()
            }
            
            switch(appPermission) {
            case .FullDropbox:
                testAllUserEndpoints(nextTest: unlink)
            case .TeamMemberFileAccess:
                testTeamMemberFileAcessActions(unlink)
            case .TeamMemberManagement:
                testTeamMemberManagementActions(unlink)
            }
        }
    }

    func checkButtons() {
        if Dropbox.authorizedClient != nil || Dropbox.authorizedTeamClient != nil {
            oauthLinkButton.hidden = true
            oauthLinkBrowserButton.hidden = true
            oauthUnlinkButton.hidden = false
            runApiTestsButton.hidden = false
        } else {
            oauthLinkButton.hidden = false
            oauthLinkBrowserButton.hidden = false
            oauthUnlinkButton.hidden = true
            runApiTestsButton.hidden = true
        }
    }
    
    /**
     To run these unit tests, you will need to do the following:
     
     Navigate to TestSwifty/ and run `pod install` to install AlamoFire dependencies.
     
     There are three types of unit tests here:
     
     1.) Regular Dropbox User API tests (requires app with 'Full Dropbox' permissions)
     2.) Dropbox Business API tests (requires app with 'Team member file access' permissions)
     3.) Dropbox Business API tests (requires app with 'Team member management' permissions)
     
     To run all of these tests, you will need three apps, one for each of the above permission types.
     
     You must test these apps one at a time.
     
     Once you have these apps, you will need to do the following:
     
     1.) Fill in user-specific data in `TestData` and `TestTeamData` in TestData.swift
     2.) For each of the above apps, you will need to add a user-specific app key. For each test run, you
     will need to call `Dropbox.setupWithAppKey` (or `Dropbox.setupWithTeamAppKey`) and supply the
     appropriate app key value, in AppDelegate.swift
     3.) Depending on which app you are currently testing, you will need to toggle the `appPermission` variable
     in AppDelegate.swift to the appropriate value.
     4.) For each of the above apps, you will need to add a user-specific URL scheme in Info.plist >
     URL types > Item 0 (Editor) > URL Schemes > click '+'. URL scheme value should be 'db-<APP KEY>'
     where '<APP KEY>' is value of your particular app's key
     
     To create an app or to locate your app's app key, please visit the App Console here:
     
     https://www.dropbox.com/developers/apps
     */
    
    // Test user app with 'Full Dropbox' permission
    func testAllUserEndpoints(asMember: Bool = false, nextTest: (() -> Void)? = nil) {
        let tester = DropboxTester()
        
        let end = {
            if let nextTest = nextTest {
                nextTest()
            } else {
                TestFormat.printAllTestsEnd()
            }
        }
        let testAuthActions = {
            self.testAuthActions(tester, nextTest: end)
        }
        let testUserActions = {
            self.testUserActions(tester, nextTest: testAuthActions)
        }
        let testSharingActions = {
            self.testSharingActions(tester, nextTest: testUserActions)
        }
        let start = {
            self.testFilesActions(tester, nextTest: testSharingActions, asMember: asMember)
        }
        
        start()
    }
    
    // Test business app with 'Team member file access' permission
    func testTeamMemberFileAcessActions(nextTest: (() -> Void)? = nil) {
        let tester = DropboxTeamTester()
        
        let end = {
            if let nextTest = nextTest {
                nextTest()
            } else {
                TestFormat.printAllTestsEnd()
            }
        }
        let testPerformActionAsMember = {
            self.testAllUserEndpoints(true, nextTest: end)
        }
        let start = {
            self.testTeamMemberFileAcessActions(tester, nextTest: testPerformActionAsMember)
        }
        
        start()
    }
    
    // Test business app with 'Team member management' permission
    func testTeamMemberManagementActions(nextTest: (() -> Void)? = nil) {
        let tester = DropboxTeamTester()
        
        let end = {
            if let nextTest = nextTest {
                nextTest()
            } else {
                TestFormat.printAllTestsEnd()
            }
        }
        let start = {
            self.testTeamMemberManagementActions(tester, nextTest: end)
        }
        
        start()
    }
    
    func testFilesActions(dropboxTester: DropboxTester, nextTest: (() -> Void), asMember: Bool = false) {
        let tester = FilesTests(tester: dropboxTester)
        
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
        let copy = {
            tester.copy(copyReferenceGet)
        }
        let uploadDataSession = {
            tester.uploadDataSession(copy)
        }
        let uploadData = {
            tester.uploadData(uploadDataSession)
        }
        let listFolder = {
            tester.listFolder(uploadData)
        }
        let createFolder = {
            tester.createFolder(listFolder)
        }
        let delete = {
            tester.delete(createFolder)
        }
        let start = {
            delete()
        }
        
        TestFormat.printTestBegin(#function)
        start()
    }
    
    func testSharingActions(dropboxTester: DropboxTester, nextTest: (() -> Void)) {
        let tester = SharingTests(tester: dropboxTester)
        
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
    
    func testUserActions(dropboxTester: DropboxTester, nextTest: (() -> Void)) {
        let tester = UserTests(tester: dropboxTester)
        
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
    
    func testAuthActions(dropboxTester: DropboxTester, nextTest: (() -> Void)) {
        let tester = AuthTests(tester: dropboxTester)
        
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
    
    func testTeamMemberFileAcessActions(dropboxTester: DropboxTeamTester, nextTest: (() -> Void)) {
        let tester = TeamTests(tester: dropboxTester)
        
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
    
    func testTeamMemberManagementActions(dropboxTester: DropboxTeamTester, nextTest: (() -> Void)) {
        let tester = TeamTests(tester: dropboxTester)
        
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

