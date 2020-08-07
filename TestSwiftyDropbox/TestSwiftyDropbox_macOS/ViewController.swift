///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Cocoa
import SwiftyDropbox

class ViewController: NSViewController {
    @IBOutlet weak var oauthTokenFlowLinkButton: NSButton!
    @IBOutlet weak var oauthCodeFlowLinkButton: NSButton!
    @IBOutlet weak var oauthUnlinkButton: NSButton!
    @IBOutlet weak var runApiTestsButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
    }

    @IBAction func oauthTokenFlowLinkButtonPressed(_ sender: AnyObject) {
        if DropboxClientsManager.authorizedClient == nil && DropboxClientsManager.authorizedTeamClient == nil {
            DropboxClientsManager.authorizeFromController(sharedWorkspace: NSWorkspace.shared, controller: self, openURL: {(url: URL) -> Void in NSWorkspace.shared.open(url)})
        }
    }

    @IBAction func oauthCodeFlowLinkButtonPressed(_ sender: AnyObject) {
        if DropboxClientsManager.authorizedClient == nil && DropboxClientsManager.authorizedTeamClient == nil {
            let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read"], includeGrantedScopes: false)
            DropboxClientsManager.authorizeFromControllerV2(
                sharedWorkspace: NSWorkspace.shared,
                controller: self,
                loadingStatusDelegate: nil,
                openURL: {(url: URL) -> Void in NSWorkspace.shared.open(url)},
                scopeRequest: scopeRequest
            )
        }
    }

    @IBAction func oauthUnlinkButtonPressed(_ sender: AnyObject) {
        DropboxClientsManager.unlinkClients()
        checkButtons()
    }
    
    @IBAction func runApiTestsButtonPressed(_ sender: AnyObject) {
        let unlink = {
            DropboxClientsManager.unlinkClients()
            self.checkButtons()
            exit(0)
        }

        switch(appPermission) {
        case .fullDropbox:
            DropboxTester().testAllUserEndpoints(false, nextTest:unlink)
        case .teamMemberFileAccess:
            DropboxTeamTester().testTeamMemberFileAcessActions(unlink)
        case .teamMemberManagement:
            DropboxTeamTester().testTeamMemberManagementActions(unlink)
        }
    }

    func checkButtons() {
        if DropboxClientsManager.authorizedClient != nil || DropboxClientsManager.authorizedTeamClient != nil {
            oauthTokenFlowLinkButton.isHidden = true
            oauthCodeFlowLinkButton.isHidden = true
            oauthUnlinkButton.isHidden = false
            runApiTestsButton.isHidden = false
        } else {
            oauthTokenFlowLinkButton.isHidden = false
            oauthCodeFlowLinkButton.isHidden = false
            oauthUnlinkButton.isHidden = true
            runApiTestsButton.isHidden = true
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
     will need to call `DropboxClientsManager.setupWithAppKey` (or `DropboxClientsManager.setupWithTeamAppKey`) and supply the
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
}
