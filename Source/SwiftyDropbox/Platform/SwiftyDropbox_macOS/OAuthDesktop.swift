///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

#if canImport(AppKit)

import Foundation
import AppKit
import WebKit

extension DropboxClientsManager {
    /// Starts a "token" flow.
    ///
    /// - Parameters:
    ///     - sharedWorkspace: The shared NSWorkspace instance in your app.
    ///     - controller: An NSViewController to present the auth flow from.
    ///     - openURL: Handler to open a URL.
    public static func authorizeFromController(sharedWorkspace: NSWorkspace, controller: NSViewController?, openURL: @escaping ((URL) -> Void)) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` before calling this method")
        let sharedDesktopApplication = DesktopSharedApplication(sharedWorkspace: sharedWorkspace, controller: controller, openURL: openURL)
        DesktopSharedApplication.sharedDesktopApplication = sharedDesktopApplication
        DropboxOAuthManager.sharedOAuthManager.authorizeFromSharedApplication(sharedDesktopApplication)
    }

    /// Starts the OAuth 2 Authorization Code Flow with PKCE.
    ///
    /// PKCE allows "authorization code" flow without "client_secret"
    /// It enables "native application", which is ensafe to hardcode client_secret in code, to use "authorization code".
    /// PKCE is more secure than "token" flow. If authorization code is compromised during
    /// transmission, it can't be used to exchange for access token without random generated
    /// code_verifier, which is stored inside this SDK.
    ///
    /// - Parameters:
    ///     - sharedApplication: The shared NSWorkspace instance in your app.
    ///     - controller: An NSViewController to present the auth flow from.
    ///     - loadingStatusDelegate: An optional delegate to handle loading experience during auth flow.
    ///       e.g. Show a loading spinner and block user interaction while loading/waiting.
    ///     - openURL: Handler to open a URL.
    ///     - scopeRequest: Contains requested scopes to obtain.
    /// - NOTE:
    ///     If auth completes successfully, A short-lived Access Token and a long-lived Refresh Token will be granted.
    ///     API calls with expired Access Token will fail with AuthError. An expired Access Token must be refreshed
    ///     in order to continue to access Dropbox APIs.
    ///
    ///     API clients set up by `DropboxClientsManager` will get token refresh logic for free.
    ///     If you need to set up `DropboxClient`/`DropboxTeamClient` without `DropboxClientsManager`,
    ///     you will have to set up the clients with an appropriate `AccessTokenProvider`.
    public static func authorizeFromControllerV2(
        sharedWorkspace: NSWorkspace,
        controller: NSViewController?,
        loadingStatusDelegate: LoadingStatusDelegate?,
        openURL: @escaping ((URL) -> Void),
        scopeRequest: ScopeRequest?
    ) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` before calling this method")
        let sharedDesktopApplication =
            DesktopSharedApplication(sharedWorkspace: sharedWorkspace, controller: controller, openURL: openURL)
        sharedDesktopApplication.loadingStatusDelegate = loadingStatusDelegate
        DesktopSharedApplication.sharedDesktopApplication = sharedDesktopApplication
        DropboxOAuthManager.sharedOAuthManager.authorizeFromSharedApplication(
            sharedDesktopApplication,
            usePKCE: true,
            scopeRequest: scopeRequest
        )
    }

    public static func setupWithAppKeyDesktop(_ appKey: String, transportClient: DropboxTransportClient? = nil) {
        setupWithOAuthManager(appKey, oAuthManager: DropboxOAuthManager(appKey: appKey), transportClient: transportClient)
    }

    public static func setupWithAppKeyMultiUserDesktop(_ appKey: String, transportClient: DropboxTransportClient? = nil, tokenUid: String?) {
        setupWithOAuthManagerMultiUser(appKey, oAuthManager: DropboxOAuthManager(appKey: appKey), transportClient: transportClient, tokenUid: tokenUid)
    }

    public static func setupWithTeamAppKeyDesktop(_ appKey: String, transportClient: DropboxTransportClient? = nil) {
        setupWithOAuthManagerTeam(appKey, oAuthManager: DropboxOAuthManager(appKey: appKey), transportClient: transportClient)
    }

    public static func setupWithTeamAppKeyMultiUserDesktop(_ appKey: String, transportClient: DropboxTransportClient? = nil, tokenUid: String?) {
        setupWithOAuthManagerMultiUserTeam(appKey, oAuthManager: DropboxOAuthManager(appKey: appKey), transportClient: transportClient, tokenUid: tokenUid)
    }
}


public class DesktopSharedApplication: SharedApplication {
    public static var sharedDesktopApplication: DesktopSharedApplication?

    let sharedWorkspace: NSWorkspace
    let controller: NSViewController?
    let openURL: ((URL) -> Void)

    weak var loadingStatusDelegate: LoadingStatusDelegate?

    public init(sharedWorkspace: NSWorkspace, controller: NSViewController?, openURL: @escaping ((URL) -> Void)) {
        self.sharedWorkspace = sharedWorkspace
        self.controller = controller
        self.openURL = openURL
    }

    public func presentErrorMessage(_ message: String, title: String) {
        let error = NSError(domain: "", code: 123, userInfo: [NSLocalizedDescriptionKey:message])
        if let controller = self.controller {
            controller.presentError(error)
        }
    }

    public func presentErrorMessageWithHandlers(_ message: String, title: String, buttonHandlers: Dictionary<String, () -> Void>) {
        presentErrorMessage(message, title: title)
    }

    // no platform-specific auth methods for OS X
    public func presentPlatformSpecificAuth(_ authURL: URL) -> Bool {
        return false
    }

    public func presentAuthChannel(_ authURL: URL, tryIntercept: @escaping ((URL) -> Bool), cancelHandler: @escaping (() -> Void)) {
        self.presentExternalApp(authURL)
    }

    public func presentExternalApp(_ url: URL) {
        self.openURL(url)
    }

    public func canPresentExternalApp(_ url: URL) -> Bool {
        return true
    }

    public func presentLoading() {
        loadingStatusDelegate?.showLoading()
    }

    public func dismissLoading() {
        loadingStatusDelegate?.dismissLoading()
    }
}

#endif
