///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import SwiftUI
import SwiftyDropbox

struct ContentView: View {
    @EnvironmentObject private var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        if viewModel.isLinked || sceneDelegate.userAuthed {
            VStack {
                Button("Run API Tests", action: runApiTests)
                    .padding()
                Button("Run Batch Upload Tests", action: runBatchUploadTests)
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
            sceneDelegate.userAuthed = false
            exit(0)
        }

        switch(appPermission) {
        case .fullDropboxScoped:
            DropboxTester().testAllUserEndpoints(asMember: false, nextTest:unlink)
        case .fullDropboxScopedForTeamTesting:
            DropboxTeamTester().testTeamMemberFileAcessActions(unlink)
        }
    }

    func runBatchUploadTests() {
        DropboxTester().testBatchUpload()
    }

    func unlink() {
        DropboxClientsManager.unlinkClients()
        viewModel.checkIsLinked()
        sceneDelegate.userAuthed = false
    }

    func link() {
        let scopeRequest: ScopeRequest
        // note if you add new scopes, you need to relogin to update your token
        switch(appPermission) {
        case .fullDropboxScoped:
            scopeRequest = ScopeRequest(scopeType: .user, scopes: DropboxTester.scopes, includeGrantedScopes: false)
        case .fullDropboxScopedForTeamTesting:
            scopeRequest = ScopeRequest(scopeType: .team, scopes: DropboxTeamTester.scopes, includeGrantedScopes: false)
        }
        DropboxClientsManager.authorizeFromControllerV2(UIApplication.shared,
                                                        controller: nil,
                                                        loadingStatusDelegate: nil,
                                                        openURL: {(url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
                                                        scopeRequest: scopeRequest)
    }
}

class ViewModel: ObservableObject {
    @Published var isLinked: Bool

    init() {
        isLinked = ViewModel.sdkIsLinked()
    }

    func checkIsLinked() {
        isLinked = ViewModel.sdkIsLinked()
    }

    private static func sdkIsLinked() -> Bool {
        return DropboxClientsManager.authorizedClient != nil || DropboxClientsManager.authorizedTeamClient != nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
