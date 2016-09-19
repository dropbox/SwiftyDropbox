///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Cocoa
import SwiftyDropbox

public enum AppPermission {
    case fullDropbox
    case teamMemberFileAccess
    case teamMemberManagement
}

let appPermission = AppPermission.fullDropbox

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var viewController: ViewController? = nil;

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        switch(appPermission) {
        case .fullDropbox:
            DropboxClientsManager.setupWithAppKeyDesktop("<FULL_DROPBOX_APP_KEY>")
        case .teamMemberFileAccess:
            DropboxClientsManager.setupWithTeamAppKeyDesktop("<TEAM_MEMBER_FILE_ACCESS_APP_KEY>")
        case .teamMemberManagement:
            DropboxClientsManager.setupWithTeamAppKeyDesktop("<TEAM_MEMBER_MANAGEMENT_APP_KEY>")
        }
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleGetURLEvent), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
        viewController = NSApplication.shared().mainWindow?.contentViewController as? ViewController
        viewController?.checkButtons()
    }

    func handleGetURLEvent(_ event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        if let aeEventDescriptor = event?.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) {
            if let urlStr = aeEventDescriptor.stringValue {
                let url = URL(string: urlStr)!
                
                switch(appPermission) {
                case .fullDropbox:
                    if let authResult = DropboxClientsManager.handleRedirectURL(url) {
                        switch authResult {
                        case .success:
                            print("Success! User is logged into Dropbox.")
                        case .cancel:
                            print("Authorization flow was manually canceled by user!")
                        case .error(_, let description):
                            print("Error: \(description)")
                        }
                    }
                case .teamMemberFileAccess:
                    if let authResult = DropboxClientsManager.handleRedirectURLTeam(url) {
                        switch authResult {
                        case .success:
                            print("Success! User is logged into Dropbox.")
                        case .cancel:
                            print("Authorization flow was manually canceled by user!")
                        case .error(_, let description):
                            print("Error: \(description)")
                        }
                    }
                case .teamMemberManagement:
                    if let authResult = DropboxClientsManager.handleRedirectURLTeam(url) {
                        switch authResult {
                        case .success:
                            print("Success! User is logged into Dropbox.")
                        case .cancel:
                            print("Authorization flow was manually canceled by user!")
                        case .error(_, let description):
                            print("Error: \(description)")
                        }
                    }
                }
            }
        }
        viewController!.checkButtons()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

