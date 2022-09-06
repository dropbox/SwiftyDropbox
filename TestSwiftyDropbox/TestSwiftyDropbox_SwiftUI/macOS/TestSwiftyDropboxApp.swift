///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import SwiftUI

@main
struct TestSwiftyDropboxApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
