///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var userAuthed: Bool = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let processInfo = ProcessInfo.processInfo.environment
        let inTestScheme = processInfo["FULL_DROPBOX_API_APP_KEY"] != nil

        // Skip setup if launching for unit tests, XCTests set up the clients themselves
        if inTestScheme {
            return
        }

        if (TestData.fullDropboxAppKey.range(of:"<") != nil) {
            print("\n\n\nMust set test data (in TestData.swift) before launching app.\n\n\nTerminating.....\n\n")
            exit(0);
        }
        switch(appPermission) {
        case .fullDropboxScoped:
            DropboxClientsManager.setupWithAppKeyDesktop(TestData.fullDropboxAppKey)
        case .fullDropboxScopedForTeamTesting:
            DropboxClientsManager.setupWithTeamAppKeyDesktop(TestData.fullDropboxAppKey)
        }
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleGetURLEvent), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    @objc func handleGetURLEvent(_ event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        if let aeEventDescriptor = event?.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) {
            if let urlStr = aeEventDescriptor.stringValue {
                guard let url = URL(string: urlStr) else { return }
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
                    DropboxClientsManager.handleRedirectURL(url, completion: oauthCompletion)
                case .fullDropboxScopedForTeamTesting:
                    DropboxClientsManager.handleRedirectURLTeam(url, completion: oauthCompletion)
                }
            }
        }
    }
}
