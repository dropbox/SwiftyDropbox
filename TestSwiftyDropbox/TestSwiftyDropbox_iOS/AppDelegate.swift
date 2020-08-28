///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import UIKit
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if (TestData.fullDropboxAppKey.range(of:"<") != nil || TestData.teamMemberFileAccessAppKey.range(of:"<") != nil || TestData.teamMemberManagementAppKey.range(of:"<") != nil) {
            print("\n\n\nMust set test data (in TestData.swift) before launching app.\n\n\nTerminating.....\n\n")
            exit(0);
        }
        switch(appPermission) {
        case .fullDropbox:
            DropboxClientsManager.setupWithAppKey(TestData.fullDropboxAppKey)
        case .teamMemberFileAccess:
            DropboxClientsManager.setupWithTeamAppKey(TestData.teamMemberFileAccessAppKey)
        case .teamMemberManagement:
            DropboxClientsManager.setupWithTeamAppKey(TestData.teamMemberManagementAppKey)
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let oauthCompletion: DropboxOAuthCompletion = {
            if let authResult = $0 {
                switch authResult {
                case .success:
                    print("Success! User is logged into DropboxClientsManager.")
                case .cancel:
                    print("Authorization flow was manually canceled by user!")
                case .error(_, let description):
                    print("Error: \(String(describing: description))")
                }
            }
            (self.window?.rootViewController as? ViewController)?.checkButtons()
        }

        let canHandleUrl: Bool
        switch(appPermission) {
        case .fullDropbox:
            canHandleUrl = DropboxClientsManager.handleRedirectURL(url, completion: oauthCompletion)
        case .teamMemberFileAccess:
            canHandleUrl = DropboxClientsManager.handleRedirectURLTeam(url, completion: oauthCompletion)
        case .teamMemberManagement:
            canHandleUrl = DropboxClientsManager.handleRedirectURLTeam(url, completion: oauthCompletion)
        }
        return canHandleUrl
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
