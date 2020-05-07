///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation
import AppKit
import WebKit

extension DropboxClientsManager {
    public static func authorizeFromController(sharedWorkspace: NSWorkspace, controller: NSViewController?, openURL: @escaping ((URL) -> Void)) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` before calling this method")
        DropboxOAuthManager.sharedOAuthManager.authorizeFromSharedApplication(DesktopSharedApplication(sharedWorkspace: sharedWorkspace, controller: controller, openURL: openURL))
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
    let sharedWorkspace: NSWorkspace
    let controller: NSViewController?
    let openURL: ((URL) -> Void)

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
        // TODO: Implement when OAuth code flow is introduced into Desktop SDK.
    }

    public func dismissLoading() {
        // TODO: Implement when OAuth code flow is introduced into Desktop SDK.
    }
}
