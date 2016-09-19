///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import UIKit
import SwiftyDropbox

public enum AppPermission {
    case fullDropbox
    case teamMemberFileAccess
    case teamMemberManagement
}

let appPermission = AppPermission.fullDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        switch(appPermission) {
        case .fullDropbox:
            DropboxClientsManager.setupWithAppKey("<FULL_DROPBOX_APP_KEY>")
        case .teamMemberFileAccess:
            DropboxClientsManager.setupWithTeamAppKey("<TEAM_MEMBER_FILE_ACCESS_APP_KEY>")
        case .teamMemberManagement:
            DropboxClientsManager.setupWithTeamAppKey("<TEAM_MEMBER_MANAGEMENT_APP_KEY>")
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        switch(appPermission) {
        case .fullDropbox:
            if let authResult = DropboxClientsManager.handleRedirectURL(url) {
                switch authResult {
                case .success:
                    print("Success! User is logged into DropboxClientsManager.")
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
                    print("Success! User is logged into DropboxClientsManager.")
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
                    print("Success! User is logged into DropboxClientsManager.")
                case .cancel:
                    print("Authorization flow was manually canceled by user!")
                case .error(_, let description):
                    print("Error: \(description)")
                }
            }
        }
        
        let mainController = self.window!.rootViewController as! ViewController
        mainController.checkButtons()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
