import UIKit
import SwiftyDropbox

public enum AppPermission {
    case FullDropbox
    case TeamMemberFileAccess
    case TeamMemberManagement
}

let appPermission = AppPermission.FullDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        switch(appPermission) {
        case .FullDropbox:
            Dropbox.setupWithAppKey("<FULL_DROPBOX_APP_KEY>")
        case .TeamMemberFileAccess:
            Dropbox.setupWithTeamAppKey("<TEAM_MEMBER_FILE_ACCESS_APP_KEY>")
        case .TeamMemberManagement:
            Dropbox.setupWithTeamAppKey("<TEAM_MEMBER_MANAGEMENT_APP_KEY>")
        }

        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        switch(appPermission) {
        case .FullDropbox:
            if let authResult = Dropbox.handleRedirectURL(url) {
                switch authResult {
                case .Success:
                    print("Success! User is logged into Dropbox.")
                case .Error(_, let description):
                    print("Error: \(description)")
                }
            }
        case .TeamMemberFileAccess:
            if let authResult = Dropbox.handleRedirectURLTeam(url) {
                switch authResult {
                case .Success:
                    print("Success! User is logged into Dropbox.")
                case .Error(_, let description):
                    print("Error: \(description)")
                }
            }
        case .TeamMemberManagement:
            if let authResult = Dropbox.handleRedirectURLTeam(url) {
                switch authResult {
                case .Success:
                    print("Success! User is logged into Dropbox.")
                case .Error(_, let description):
                    print("Error: \(description)")
                }
            }
        }

        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
