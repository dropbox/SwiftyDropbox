///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Cocoa
import SwiftyDropbox

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var viewController: ViewController? = nil;

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if (TestData.fullDropboxAppKey.range(of:"<") != nil || TestData.teamMemberFileAccessAppKey.range(of:"<") != nil || TestData.teamMemberManagementAppKey.range(of:"<") != nil) {
            print("\n\n\nMust set test data (in TestData.swift) before launching app.\n\n\nTerminating.....\n\n")
            exit(0);
        }
        switch(appPermission) {
        case .fullDropbox:
            DropboxClientsManager.setupWithAppKeyDesktop(TestData.fullDropboxAppKey)
        case .teamMemberFileAccess:
            DropboxClientsManager.setupWithTeamAppKeyDesktop(TestData.teamMemberFileAccessAppKey)
        case .teamMemberManagement:
            DropboxClientsManager.setupWithTeamAppKeyDesktop(TestData.teamMemberManagementAppKey)
        }
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleGetURLEvent), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))

        viewController = NSApplication.shared.windows[0].contentViewController as? ViewController
        self.checkButtons()
    }

    @objc func handleGetURLEvent(_ event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        if let aeEventDescriptor = event?.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) {
            if let urlStr = aeEventDescriptor.stringValue {
                let url = URL(string: urlStr)!
                let oauthCompletion: DropboxOAuthCompletion = {
                    if let authResult = $0 {
                        switch authResult {
                        case .success:
                            print("Success! User is logged into Dropbox.")
                        case .cancel:
                            print("Authorization flow was manually canceled by user!")
                        case .error(_, let description):
                            print("Error: \(String(describing: description))")
                        }
                    }
                    self.checkButtons()
                }

                switch(appPermission) {
                case .fullDropbox:
                    DropboxClientsManager.handleRedirectURL(url, completion: oauthCompletion)
                case .teamMemberFileAccess, .teamMemberManagement:
                    DropboxClientsManager.handleRedirectURLTeam(url, completion: oauthCompletion)
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func checkButtons() {
        viewController?.checkButtons()
    }
}

