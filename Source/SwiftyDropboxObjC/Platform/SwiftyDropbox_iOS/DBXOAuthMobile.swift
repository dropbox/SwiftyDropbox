///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

#if os(iOS)
import UIKit

extension DBXDropboxClientsManager {
    /// Starts a "token" flow.
    ///
    /// This method should no longer be used.
    /// Long-lived access tokens are deprecated. See https://dropbox.tech/developers/migrating-app-permissions-and-access-tokens.
    /// Please use `authorizeFromControllerV2` instead.
    ///
    /// - Parameters:
    ///     - sharedApplication: The shared UIApplication instance in your app.
    ///     - controller: A UIViewController to present the auth flow from. This should be the top-most view controller. Reference is weakly held.
    ///     - openURL: Handler to open a URL.
    @objc
    @available(
        *,
        deprecated,
        message: "This method was used for long-lived access tokens, which are now deprecated. Please use `authorizeFromControllerV2` instead."
    )
    public static func authorizeFromController(
        _ sharedApplication: UIApplication,
        controller: UIViewController?,
        openURL: @escaping ((URL) -> Void)
    ) {
        DropboxClientsManager.authorizeFromController(sharedApplication, controller: controller, openURL: openURL)
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
    ///     - sharedApplication: The shared UIApplication instance in your app.
    ///     - controller: A UIViewController to present the auth flow from. This should be the top-most view controller. Reference is weakly held.
    ///     - loadingStatusDelegate: An optional delegate to handle loading experience during auth flow.
    ///       e.g. Show a loading spinner and block user interaction while loading/waiting.
    ///       If a delegate is not provided, the SDK will show a default loading spinner when necessary.
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
        _ sharedApplication: UIApplication,
        controller: UIViewController?,
        loadingStatusDelegate: LoadingStatusDelegate?,
        openURL: @escaping ((URL) -> Void),
        scopeRequest: DBXScopeRequest?
    ) {
        DropboxClientsManager.authorizeFromControllerV2(
            sharedApplication,
            controller: controller,
            loadingStatusDelegate: loadingStatusDelegate,
            openURL: openURL,
            scopeRequest: scopeRequest?.swift
        )
    }

    @objc
    public static func setupWithAppKey(
        _ appKey: String
    ) {
        setupWithAppKey(
            appKey,
            transportClient: nil,
            backgroundTransportClient: nil,
            secureStorageAccess: DBXSecureStorageAccessDefaultImpl(),
            includeBackgroundClient: false,
            requestsToReconnect: nil
        )
    }

    @objc
    public static func setupWithAppKey(
        _ appKey: String,
        transportClient: DBXDropboxTransportClient? = nil,
        backgroundTransportClient: DBXDropboxTransportClient? = nil,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl(),
        includeBackgroundClient: Bool = false,
        requestsToReconnect: (([DBXReconnectionResult]) -> Void)? = nil
    ) {
        DropboxClientsManager.setupWithAppKey(
            appKey,
            transportClient: transportClient?.swift,
            backgroundTransportClient: backgroundTransportClient?.swift,
            secureStorageAccess: secureStorageAccess.swift,
            includeBackgroundClient: includeBackgroundClient,
            requestsToReconnect: { swiftRequests in
                requestsToReconnect?(objcRequests(from: swiftRequests))
            }
        )
    }

    @objc
    public static func setupWithAppKey(
        _ appKey: String,
        sessionConfiguration: DBXNetworkSessionConfiguration?,
        backgroundSessionConfiguration: DBXNetworkSessionConfiguration?,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl(),
        includeBackgroundClient: Bool = false,
        requestsToReconnect: (([DBXReconnectionResult]) -> Void)? = nil
    ) {
        DropboxClientsManager.setupWithAppKey(
            appKey,
            sessionConfiguration: sessionConfiguration?.swift,
            backgroundSessionConfiguration: backgroundSessionConfiguration?.swift,
            secureStorageAccess: secureStorageAccess.swift,
            includeBackgroundClient: includeBackgroundClient,
            requestsToReconnect: { swiftRequests in
                requestsToReconnect?(objcRequests(from: swiftRequests))
            }
        )
    }

    @objc
    public static func setupWithAppKey(
        _ appKey: String, backgroundSessionIdentifier: String,
        sharedContainerIdentifier: String? = nil,
        requestsToReconnect: @escaping ([DBXReconnectionResult]) -> Void
    ) {
        setupWithAppKey(
            appKey,
            backgroundSessionIdentifier: backgroundSessionIdentifier,
            sharedContainerIdentifier: sharedContainerIdentifier,
            secureStorageAccess: DBXSecureStorageAccessDefaultImpl(),
            requestsToReconnect: requestsToReconnect
        )
    }

    @objc
    public static func setupWithAppKey(
        _ appKey: String, backgroundSessionIdentifier: String,
        sharedContainerIdentifier: String? = nil,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl(),
        requestsToReconnect: @escaping ([DBXReconnectionResult]) -> Void
    ) {
        let backgroundNetworkSessionConfiguration = NetworkSessionConfiguration.background(
            withIdentifier: backgroundSessionIdentifier,
            sharedContainerIdentifier: sharedContainerIdentifier
        ).objc
        setupWithAppKey(
            appKey,
            sessionConfiguration: nil,
            backgroundSessionConfiguration: backgroundNetworkSessionConfiguration,
            secureStorageAccess: secureStorageAccess,
            includeBackgroundClient: true,
            requestsToReconnect: requestsToReconnect
        )
    }

    @objc
    public static func setupWithAppKeyMultiUser(
        _ appKey: String,
        tokenUid: String?
    ) {
        setupWithAppKeyMultiUser(
            appKey,
            transportClient: nil,
            backgroundTransportClient: nil,
            tokenUid: tokenUid,
            secureStorageAccess: DBXSecureStorageAccessDefaultImpl(),
            includeBackgroundClient: false,
            requestsToReconnect: nil
        )
    }

    @objc
    public static func setupWithAppKeyMultiUser(
        _ appKey: String,
        transportClient: DBXDropboxTransportClient? = nil,
        backgroundTransportClient: DBXDropboxTransportClient? = nil,
        tokenUid: String?,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl(),
        includeBackgroundClient: Bool = false,
        requestsToReconnect: (([DBXReconnectionResult]) -> Void)? = nil
    ) {
        DropboxClientsManager.setupWithAppKeyMultiUser(
            appKey,
            transportClient: transportClient?.swift,
            backgroundTransportClient: backgroundTransportClient?.swift,
            tokenUid: tokenUid,
            secureStorageAccess: secureStorageAccess.swift,
            includeBackgroundClient: includeBackgroundClient,
            requestsToReconnect: { swiftRequests in
                requestsToReconnect?(objcRequests(from: swiftRequests))
            }
        )
    }

    @objc
    public static func setupWithAppKeyMultiUser(
        _ appKey: String,
        sessionConfiguration: DBXNetworkSessionConfiguration?,
        backgroundSessionConfiguration: DBXNetworkSessionConfiguration?,
        tokenUid: String?,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl(),
        includeBackgroundClient: Bool = false,
        requestsToReconnect: (([DBXReconnectionResult]) -> Void)? = nil
    ) {
        DropboxClientsManager.setupWithAppKeyMultiUser(
            appKey,
            sessionConfiguration: sessionConfiguration?.swift,
            backgroundSessionConfiguration: backgroundSessionConfiguration?.swift,
            tokenUid: tokenUid,
            includeBackgroundClient: includeBackgroundClient,
            requestsToReconnect: { swiftRequests in
                requestsToReconnect?(objcRequests(from: swiftRequests))
            }
        )
    }

    @objc
    public static func setupWithAppKeyMultiUser(
        _ appKey: String,
        backgroundSessionIdentifier: String,
        sharedContainerIdentifier: String? = nil,
        tokenUid: String?,
        requestsToReconnect: @escaping ([DBXReconnectionResult]) -> Void
    ) {
        setupWithAppKeyMultiUser(
            appKey,
            backgroundSessionIdentifier: backgroundSessionIdentifier,
            sharedContainerIdentifier: sharedContainerIdentifier,
            tokenUid: tokenUid,
            secureStorageAccess: DBXSecureStorageAccessDefaultImpl(),
            requestsToReconnect: requestsToReconnect
        )
    }

    @objc
    public static func setupWithAppKeyMultiUser(
        _ appKey: String,
        backgroundSessionIdentifier: String,
        sharedContainerIdentifier: String? = nil,
        tokenUid: String?,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl(),
        requestsToReconnect: @escaping ([DBXReconnectionResult]) -> Void
    ) {
        let backgroundNetworkSessionConfiguration = NetworkSessionConfiguration.background(
            withIdentifier: backgroundSessionIdentifier,
            sharedContainerIdentifier: sharedContainerIdentifier
        ).objc
        setupWithAppKeyMultiUser(
            appKey,
            sessionConfiguration: nil,
            backgroundSessionConfiguration: backgroundNetworkSessionConfiguration,
            tokenUid: tokenUid,
            secureStorageAccess: secureStorageAccess,
            includeBackgroundClient: true,
            requestsToReconnect: requestsToReconnect
        )
    }

    @objc
    public static func setupWithTeamAppKey(
        _ appKey: String
    ) {
        setupWithTeamAppKey(appKey, transportClient: nil, secureStorageAccess: DBXSecureStorageAccessDefaultImpl())
    }

    @objc
    public static func setupWithTeamAppKey(
        _ appKey: String,
        transportClient: DBXDropboxTransportClient? = nil,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl()
    ) {
        DropboxClientsManager.setupWithTeamAppKey(appKey, transportClient: transportClient?.swift, secureStorageAccess: secureStorageAccess.swift)
    }

    @objc
    public static func setupWithTeamAppKey(
        _ appKey: String,
        sessionConfiguration: DBXNetworkSessionConfiguration?,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl()
    ) {
        DropboxClientsManager.setupWithTeamAppKey(appKey, sessionConfiguration: sessionConfiguration?.swift, secureStorageAccess: secureStorageAccess.swift)
    }

    @objc
    public static func setupWithTeamAppKeyMultiUser(
        _ appKey: String,
        transportClient: DBXDropboxTransportClient? = nil,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl(),
        tokenUid: String?
    ) {
        DropboxClientsManager.setupWithTeamAppKeyMultiUser(
            appKey,
            transportClient: transportClient?.swift,
            secureStorageAccess: secureStorageAccess.swift,
            tokenUid: tokenUid
        )
    }

    @objc
    public static func setupWithTeamAppKeyMultiUser(
        _ appKey: String,
        tokenUid: String?
    ) {
        setupWithTeamAppKeyMultiUser(
            appKey,
            transportClient: nil,
            secureStorageAccess: DBXSecureStorageAccessDefaultImpl(),
            tokenUid: tokenUid
        )
    }

    @objc
    public static func setupWithTeamAppKeyMultiUser(
        _ appKey: String,
        sessionConfiguration: DBXNetworkSessionConfiguration?,
        secureStorageAccess: DBXSecureStorageAccess = DBXSecureStorageAccessDefaultImpl(),
        tokenUid: String?
    ) {
        DropboxClientsManager.setupWithTeamAppKeyMultiUser(
            appKey,
            sessionConfiguration: sessionConfiguration?.swift,
            secureStorageAccess: secureStorageAccess.swift,
            tokenUid: tokenUid
        )
    }
}

#endif

public class DBXDropboxMobileOAuthManager: DBXDropboxOAuthManager {
    let mobileSwift: DropboxMobileOAuthManager

    init(mobileSwift: DropboxMobileOAuthManager) {
        self.mobileSwift = mobileSwift
        super.init(swift: mobileSwift)
    }

    @objc
    public init(
        appKey: String,
        host: String = "www.dropbox.com",
        secureStorageAccess: DBXSecureStorageAccess,
        dismissSharedAppAuthController: @escaping () -> Void
    ) {
        self.mobileSwift = DropboxMobileOAuthManager(
            appKey: appKey,
            secureStorageAccess: secureStorageAccess.swift,
            dismissSharedAppAuthController: dismissSharedAppAuthController
        )
        super.init(swift: mobileSwift)
    }
}
