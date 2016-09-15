import Cocoa
import SwiftyDropbox

public enum AppPermission {
    case FullDropbox
    case TeamMemberFileAccess
    case TeamMemberManagement
}

let appPermission = AppPermission.FullDropbox

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var viewController: ViewController? = nil;

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        switch(appPermission) {
        case .FullDropbox:
          Dropbox.setupWithAppKey("<FULL_DROPBOX_APP_KEY>")
        case .TeamMemberFileAccess:
          Dropbox.setupWithTeamAppKey("<TEAM_MEMBER_FILE_ACCESS_APP_KEY>")
        case .TeamMemberManagement:
          Dropbox.setupWithTeamAppKey("<TEAM_MEMBER_MANAGEMENT_APP_KEY>")
        }
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: #selector(handleGetURLEvent), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        NSApp.activateIgnoringOtherApps(true)
        viewController = NSApplication.sharedApplication().mainWindow?.contentViewController as? ViewController
        viewController?.checkButtons()
    }

    func handleGetURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        if let aeEventDescriptor = event?.paramDescriptorForKeyword(AEKeyword(keyDirectObject)) {
            if let urlStr = aeEventDescriptor.stringValue {
                let url = NSURL(string: urlStr)!
                
                switch(appPermission) {
                case .FullDropbox:
                    if let authResult = Dropbox.handleRedirectURL(url) {
                        switch authResult {
                        case .Success:
                            print("Success! User is logged into Dropbox.")
                        case .Cancel:
                            print("Authorization flow was manually canceled by user!")
                        case .Error(_, let description):
                            print("Error: \(description)")
                        }
                    }
                case .TeamMemberFileAccess:
                    if let authResult = Dropbox.handleRedirectURLTeam(url) {
                        switch authResult {
                        case .Success:
                            print("Success! User is logged into Dropbox.")
                        case .Cancel:
                            print("Authorization flow was manually canceled by user!")
                        case .Error(_, let description):
                            print("Error: \(description)")
                        }
                    }
                case .TeamMemberManagement:
                    if let authResult = Dropbox.handleRedirectURLTeam(url) {
                        switch authResult {
                        case .Success:
                            print("Success! User is logged into Dropbox.")
                        case .Cancel:
                            print("Authorization flow was manually canceled by user!")
                        case .Error(_, let description):
                            print("Error: \(description)")
                        }
                    }
                }
            }
        }
        viewController!.checkButtons()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

