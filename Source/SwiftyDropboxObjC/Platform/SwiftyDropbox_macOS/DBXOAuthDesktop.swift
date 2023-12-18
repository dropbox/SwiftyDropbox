///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

#if os(macOS)

import AppKit

extension DBXDropboxClientsManager {
    /// Starts a "token" flow.
    ///
    /// This method should no longer be used.
    /// Long-lived access tokens are deprecated. See https://dropbox.tech/developers/migrating-app-permissions-and-access-tokens.
    /// Please use `authorizeFromControllerV2` instead.
    /// - Parameters:
    ///     - sharedApplication: The shared NSApplication instance in your app.
    ///     - controller: An NSViewController to present the auth flow from. Reference is weakly held.
    ///     - openURL: Handler to open a URL.
    @objc
    @available(
        *,
        deprecated,
        message: "This method was used for long-lived access tokens, which are now deprecated. Please use `authorizeFromControllerV2` instead."
    )
    public static func authorizeFromController(
        sharedApplication: NSApplication,
        controller: NSViewController?,
        openURL: @escaping ((URL) -> Void)
    ) {
        DropboxClientsManager.authorizeFromController(sharedApplication: sharedApplication, controller: controller, openURL: openURL)
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
    @objc
    public static func authorizeFromControllerV2(
        sharedApplication: NSApplication,
        controller: NSViewController?,
        loadingStatusDelegate: LoadingStatusDelegate?,
        openURL: @escaping ((URL) -> Void),
        scopeRequest: DBXScopeRequest?
    ) {
        DropboxClientsManager.authorizeFromControllerV2(
            sharedApplication: sharedApplication,
            controller: controller,
            loadingStatusDelegate: loadingStatusDelegate,
            openURL: openURL,
            scopeRequest: scopeRequest?.swift
        )
    }

    @objc
    public static func setupWithAppKeyDesktop(
        _ appKey: String
    ) {
        setupWithAppKeyDesktop(appKey, transportClient: nil, secureStorageAccess: DBXSecureStorageAccessDefaultImpl())
    }

    @objc
    public static func setupWithAppKeyDesktop(
        _ appKey: String,
        transportClient: DBXDropboxTransportClient? = nil,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl()
    ) {
        DropboxClientsManager.setupWithAppKeyDesktop(appKey, transportClient: transportClient?.swift, secureStorageAccess: secureStorageAccess.swift)
    }

    @objc
    public static func setupWithAppKeyMultiUserDesktop(
        _ appKey: String,
        tokenUid: String?
    ) {
        setupWithAppKeyMultiUserDesktop(
            appKey,
            transportClient: nil,
            secureStorageAccess: DBXSecureStorageAccessDefaultImpl(),
            tokenUid: tokenUid
        )
    }

    @objc
    public static func setupWithAppKeyMultiUserDesktop(
        _ appKey: String,
        transportClient: DBXDropboxTransportClient? = nil,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl(),
        tokenUid: String?
    ) {
        DropboxClientsManager.setupWithAppKeyMultiUserDesktop(
            appKey,
            transportClient: transportClient?.swift,
            secureStorageAccess: secureStorageAccess.swift,
            tokenUid: tokenUid
        )
    }

    @objc
    public static func setupWithTeamAppKeyDesktop(
        _ appKey: String
    ) {
        setupWithTeamAppKeyDesktop(appKey, transportClient: nil, secureStorageAccess: DBXSecureStorageAccessDefaultImpl())
    }

    @objc
    public static func setupWithTeamAppKeyDesktop(
        _ appKey: String,
        transportClient: DBXDropboxTransportClient? = nil,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl()
    ) {
        DropboxClientsManager.setupWithTeamAppKeyDesktop(appKey, transportClient: transportClient?.swift, secureStorageAccess: secureStorageAccess.swift)
    }

    @objc
    public static func setupWithTeamAppKeyMultiUserDesktop(
        _ appKey: String,
        tokenUid: String?
    ) {
        setupWithTeamAppKeyMultiUserDesktop(
            appKey,
            transportClient: nil,
            secureStorageAccess: DBXSecureStorageAccessDefaultImpl(),
            tokenUid: tokenUid
        )
    }

    @objc
    public static func setupWithTeamAppKeyMultiUserDesktop(
        _ appKey: String,
        transportClient: DBXDropboxTransportClient? = nil,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl(),
        tokenUid: String?
    ) {
        DropboxClientsManager.setupWithTeamAppKeyMultiUserDesktop(
            appKey,
            transportClient: transportClient?.swift,
            secureStorageAccess: secureStorageAccess.swift,
            tokenUid: tokenUid
        )
    }
}

#endif
