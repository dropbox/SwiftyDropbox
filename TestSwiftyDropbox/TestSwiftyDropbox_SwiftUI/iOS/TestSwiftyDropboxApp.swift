///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import SwiftUI

@main
struct TestSwiftyDropboxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
