///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import SwiftUI
import SwiftyDropbox
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        DropboxClientsManager.loggingClosure = { _, message in
            BackgroundTestLogger.log(message)
        }

        DropboxClientsManager.logBackgroundSession("willFinishLaunchingWithOptions \(launchOptions?.description ?? "none")")
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DropboxClientsManager.logBackgroundSession("didFinishLaunchingWithOptions \(launchOptions?.description ?? "none")")

        let processInfo = ProcessInfo.processInfo.environment
        let inTestScheme = processInfo["FULL_DROPBOX_API_APP_KEY"] != nil

        // Skip setup if launching for unit tests, XCTests set up the clients themselves
        if inTestScheme {
            return true
        }

        if TestData.fullDropboxAppKey.range(of: "<") != nil {
            print("\n\n\nMust set test data (in TestData.swift) before launching app.\n\n\nTerminating.....\n\n")
            exit(0)
        }

        switch appPermission {
        case .fullDropboxScoped:
            DropboxClientsManager.setupWithAppKey(
                TestData.fullDropboxAppKey,
                backgroundSessionIdentifier: TestData.backgroundSessionIdentifier,
                sharedContainerIdentifier: TestData.sharedContainerIdentifier,
                requestsToReconnect: { requestResults in
                    self.processRequestResults(requestResults: requestResults)
                }
            )
        case .fullDropboxScopedForTeamTesting:
            DropboxClientsManager.setupWithTeamAppKey(TestData.fullDropboxAppKey)
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
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
        switch appPermission {
        case .fullDropboxScoped:
            canHandleUrl = DropboxClientsManager.handleRedirectURL(
                url,
                includeBackgroundClient: true,
                completion: oauthCompletion
            )
        case .fullDropboxScopedForTeamTesting:
            canHandleUrl = DropboxClientsManager.handleRedirectURLTeam(url, completion: oauthCompletion)
        }
        return canHandleUrl
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        DropboxClientsManager.logBackgroundSession("handleEventsForBackgroundURLSession \(identifier)")

        let actionExtensionCreationInfo: BackgroundExtensionSessionCreationInfo = .init(defaultInfo: .init(
            backgroundSessionIdentifier: TestData.extensionBackgroundSessionIdentifier,
            sharedContainerIdentifier: TestData.sharedContainerIdentifier
        ))

        DropboxClientsManager.handleEventsForBackgroundURLSession(
            with: identifier,
            creationInfos: [actionExtensionCreationInfo],
            completionHandler: completionHandler,
            requestsToReconnect: { requestResults in
                self.processRequestResults(requestResults: requestResults)
            }
        )
    }

    private func processRequestResults(requestResults: [Result<DropboxBaseRequestBox, ReconnectionError>]) {
        if #available(iOS 16.0, *) {
            DebugBackgroundSessionViewModel.processReconnect(requestResults: requestResults)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        DropboxClientsManager.logBackgroundSession("applicationWillResignActive")

        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        DropboxClientsManager.logBackgroundSession("applicationDidEnterBackground")

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        DropboxClientsManager.logBackgroundSession("applicationWillEnterForeground")

        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        DropboxClientsManager.logBackgroundSession("applicationDidBecomeActive")

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DropboxClientsManager.logBackgroundSession("applicationWillTerminate")

        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
