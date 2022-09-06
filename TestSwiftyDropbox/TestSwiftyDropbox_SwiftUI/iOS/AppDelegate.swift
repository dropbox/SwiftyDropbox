///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let processInfo = ProcessInfo.processInfo.environment
        let inTestScheme = processInfo["FULL_DROPBOX_API_APP_KEY"] != nil

        // Skip setup if launching for unit tests, XCTests set up the clients themselves
        if inTestScheme {
            return true
        }

        if (TestData.fullDropboxAppKey.range(of:"<") != nil) {
            print("\n\n\nMust set test data (in TestData.swift) before launching app.\n\n\nTerminating.....\n\n")
            exit(0);
        }
        switch(appPermission) {
        case .fullDropboxScoped:
            DropboxClientsManager.setupWithAppKey(TestData.fullDropboxAppKey)
        case .fullDropboxScopedForTeamTesting:
            DropboxClientsManager.setupWithTeamAppKey(TestData.fullDropboxAppKey)
        }

        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
      }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    @Published var userAuthed: Bool = false

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        let oauthCompletion: DropboxOAuthCompletion = { [weak self] in
            if let authResult = $0 {
                switch authResult {
                case .success:
                    print("Success! User is logged into DropboxClientsManager.")
                    self?.userAuthed = true
                case .cancel:
                    print("Authorization flow was manually canceled by user!")
                    self?.userAuthed = false
                case .error(_, let description):
                    print("Error: \(String(describing: description))")
                    self?.userAuthed = false
                }
            }
        }

        switch(appPermission) {
        case .fullDropboxScoped:
            let _ = DropboxClientsManager.handleRedirectURL(url, completion: oauthCompletion)
        case .fullDropboxScopedForTeamTesting:
            let _ = DropboxClientsManager.handleRedirectURLTeam(url, completion: oauthCompletion)
        }

    }

}
