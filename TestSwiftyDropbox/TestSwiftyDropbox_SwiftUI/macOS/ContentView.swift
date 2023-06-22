///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import SwiftUI
import SwiftyDropbox

struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        if viewModel.isLinked || appDelegate.userAuthed {
            VStack {
                Button("Run API Tests", action: runApiTests)
                    .padding()
                Button("Unlink Dropbox Account", action: unlink)
                    .padding()
            }
            .padding()
        } else {
            Button("Link Dropbox (pkce code flow)", action: link)
                .padding()
        }
    }

    func runApiTests() {
        let unlink = {
            DropboxClientsManager.unlinkClients()
            viewModel.checkIsLinked()
            appDelegate.userAuthed = false
            exit(0)
        }

        switch appPermission {
        case .fullDropboxScoped:
            DropboxTester().testAllUserEndpoints(asMember: false, nextTest: unlink)
        case .fullDropboxScopedForTeamTesting:
            DropboxTeamTester().testTeamMemberFileAcessActions(unlink)
        }
    }

    func unlink() {
        DropboxClientsManager.unlinkClients()
        viewModel.checkIsLinked()
        appDelegate.userAuthed = false
    }

    func link() {
        let scopeRequest: ScopeRequest
        // note if you add new scopes, you need to relogin to update your token
        switch appPermission {
        case .fullDropboxScoped:
            scopeRequest = ScopeRequest(scopeType: .user, scopes: DropboxTester.scopes, includeGrantedScopes: false)
        case .fullDropboxScopedForTeamTesting:
            scopeRequest = ScopeRequest(scopeType: .team, scopes: DropboxTeamTester.scopes, includeGrantedScopes: false)
        }

        DropboxClientsManager.authorizeFromControllerV2(
            sharedApplication: NSApplication.shared,
            controller: nil,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in NSWorkspace.shared.open(url) },
            scopeRequest: scopeRequest
        )
    }
}

class ViewModel: ObservableObject {
    @Published var isLinked: Bool

    init() {
        self.isLinked = ViewModel.sdkIsLinked()
    }

    func checkIsLinked() {
        isLinked = ViewModel.sdkIsLinked()
    }

    private static func sdkIsLinked() -> Bool {
        DropboxClientsManager.authorizedClient != nil || DropboxClientsManager.authorizedTeamClient != nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
