///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

#if os(macOS)

import Foundation
import AppKit
import WebKit

extension DropboxClientsManager {
    /// Starts a "token" flow.
    ///
    /// This method should no longer be used.
    /// Long-lived access tokens are deprecated. See https://dropbox.tech/developers/migrating-app-permissions-and-access-tokens.
    /// Please use `authorizeFromControllerV2` instead.
    /// - Parameters:
    ///     - sharedApplication: The shared NSApplication instance in your app.
    ///     - controller: An NSViewController to present the auth flow from. Reference is weakly held.
    ///     - openURL: Handler to open a URL.
    @available(*, deprecated, message: "This method was used for long-lived access tokens, which are now deprecated. Please use `authorizeFromControllerV2` instead.")
    public static func authorizeFromController(sharedApplication: NSApplication,
                                               controller: NSViewController?,
                                               openURL: @escaping ((URL) -> Void)) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` before calling this method")
        let sharedDesktopApplication = DesktopSharedApplication(sharedApplication: sharedApplication, controller: controller, openURL: openURL)
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
    ///     - sharedApplication: The shared NSApplication instance in your app.
    ///     - controller: An NSViewController to present the auth flow from. Reference is weakly held.
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
    public static func authorizeFromControllerV2(sharedApplication: NSApplication,
                                                 controller: NSViewController?,
                                                 loadingStatusDelegate: LoadingStatusDelegate?,
                                                 openURL: @escaping ((URL) -> Void),
                                                 scopeRequest: ScopeRequest?
    ) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` before calling this method")
        let sharedDesktopApplication =
            DesktopSharedApplication(sharedApplication: sharedApplication, controller: controller, openURL: openURL)
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

    let sharedApplication: NSApplication
    weak var controller: NSViewController?
    let openURL: ((URL) -> Void)

    weak var loadingStatusDelegate: LoadingStatusDelegate?

    /// Reference to controller is weakly held.
    public init(sharedApplication: NSApplication, controller: NSViewController?, openURL: @escaping ((URL) -> Void)) {
        self.sharedApplication = sharedApplication
        self.controller = controller
        self.openURL = openURL

        if let controller = controller {
            self.controller = controller
        } else {
            self.controller = sharedApplication.keyWindow?.contentViewController
        }
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
