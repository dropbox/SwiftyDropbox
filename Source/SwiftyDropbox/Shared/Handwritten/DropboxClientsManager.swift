///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation
import Alamofire

/// This is a convenience class for the typical single user case. To use this
/// class, see details in the tutorial at:
/// https://www.dropbox.com/developers/documentation/swift#tutorial
///
/// For information on the available API methods, see the documentation for DropboxClient
open class DropboxClientsManager {
    /// An authorized client. This will be set to nil if unlinked.
    public static var authorizedClient: DropboxClient?

    /// An authorized team client. This will be set to nil if unlinked.
    public static var authorizedTeamClient: DropboxTeamClient?

    /// Sets up access to the Dropbox User API
    static func setupWithOAuthManager(_ appKey: String, oAuthManager: DropboxOAuthManager, transportClient: DropboxTransportClient?) {
        precondition(DropboxOAuthManager.sharedOAuthManager == nil, "Only call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` once")
        DropboxOAuthManager.sharedOAuthManager = oAuthManager

        if let token = DropboxOAuthManager.sharedOAuthManager.getFirstAccessToken() {
            setupAuthorizedClient(token, transportClient:transportClient)
        }
        Keychain.checkAccessibilityMigrationOneTime
    }

    /// Sets up access to the Dropbox User API
    static func setupWithOAuthManagerMultiUser(_ appKey: String, oAuthManager: DropboxOAuthManager, transportClient: DropboxTransportClient?, tokenUid: String?) {
        precondition(DropboxOAuthManager.sharedOAuthManager == nil, "Only call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` once")
        DropboxOAuthManager.sharedOAuthManager = oAuthManager

        if let token = DropboxOAuthManager.sharedOAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedClient(token, transportClient:transportClient)
        }
        Keychain.checkAccessibilityMigrationOneTime
    }

    /// Sets up access to the Dropbox Business (Team) API
    static func setupWithOAuthManagerTeam(_ appKey: String, oAuthManager: DropboxOAuthManager, transportClient: DropboxTransportClient?) {
        precondition(DropboxOAuthManager.sharedOAuthManager == nil, "Only call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` once")
        DropboxOAuthManager.sharedOAuthManager = oAuthManager

        if let token = DropboxOAuthManager.sharedOAuthManager.getFirstAccessToken() {
            setupAuthorizedTeamClient(token, transportClient:transportClient)
        }
        Keychain.checkAccessibilityMigrationOneTime
    }

    /// Sets up access to the Dropbox Business (Team) API in multi-user case
    static func setupWithOAuthManagerMultiUserTeam(_ appKey: String, oAuthManager: DropboxOAuthManager, transportClient: DropboxTransportClient?, tokenUid: String?) {
        precondition(DropboxOAuthManager.sharedOAuthManager == nil, "Only call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` once")
        DropboxOAuthManager.sharedOAuthManager = oAuthManager

        if let token = DropboxOAuthManager.sharedOAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedTeamClient(token, transportClient:transportClient)
        }
        Keychain.checkAccessibilityMigrationOneTime
    }

    public static func reauthorizeClient(_ tokenUid: String) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        if let token = DropboxOAuthManager.sharedOAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedClient(token, transportClient:nil)
        }
        Keychain.checkAccessibilityMigrationOneTime
    }

    public static func reauthorizeTeamClient(_ tokenUid: String) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        if let token = DropboxOAuthManager.sharedOAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedTeamClient(token, transportClient:nil)
        }
        Keychain.checkAccessibilityMigrationOneTime
    }

    static func setupAuthorizedClient(_ accessToken: DropboxAccessToken?, transportClient: DropboxTransportClient?) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        if let accessToken = accessToken, let oauthManager = DropboxOAuthManager.sharedOAuthManager {
            let accessTokenProvider = oauthManager.accessTokenProviderForToken(accessToken)
            if let transportClient = transportClient {
                transportClient.accessTokenProvider = accessTokenProvider
                authorizedClient = DropboxClient(transportClient: transportClient)
            } else {
                authorizedClient = DropboxClient(accessTokenProvider: accessTokenProvider)
            }
        } else {
            if let transportClient = transportClient {
                authorizedClient = DropboxClient(transportClient: transportClient)
            }
        }
    }

    static func setupAuthorizedTeamClient(_ accessToken: DropboxAccessToken?, transportClient: DropboxTransportClient?) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        if let accessToken = accessToken, let oauthManager = DropboxOAuthManager.sharedOAuthManager {
            let accessTokenProvider = oauthManager.accessTokenProviderForToken(accessToken)
            if let transportClient = transportClient {
                transportClient.accessTokenProvider = accessTokenProvider
                authorizedTeamClient = DropboxTeamClient(transportClient: transportClient)
            } else {
                authorizedTeamClient = DropboxTeamClient(accessTokenProvider: accessTokenProvider)
            }
        } else {
            if let transportClient = transportClient {
                authorizedTeamClient = DropboxTeamClient(transportClient: transportClient)
            }
        }
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    ///
    /// - parameters:
    ///     - url: The URL to attempt to handle.
    ///     - completion: The callback closure to receive auth result.
    /// - returns: Whether the redirect URL can be handled.
    ///
    @discardableResult
    public static func handleRedirectURL(_ url: URL, completion: @escaping DropboxOAuthCompletion) -> Bool {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")
        return DropboxOAuthManager.sharedOAuthManager.handleRedirectURL(url, completion: { result in
            if let result = result {
                switch result {
                case .success(let accessToken):
                    setupAuthorizedClient(accessToken, transportClient: nil)
                case .cancel, .error:
                    break
                }
            }
            completion(result)
        })
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    ///
    /// - parameters:
    ///     - url: The URL to attempt to handle.
    ///     - completion: The callback closure to receive auth result.
    /// - returns: Whether the redirect URL can be handled.
    ///
    @discardableResult
    public static func handleRedirectURLTeam(_ url: URL, completion: @escaping DropboxOAuthCompletion) -> Bool {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithTeamAppKey` before calling this method")
        return DropboxOAuthManager.sharedOAuthManager.handleRedirectURL(url, completion: { result in
            if let result = result {
                switch result {
                case .success(let accessToken):
                    setupAuthorizedTeamClient(accessToken, transportClient: nil)
                case .cancel, .error:
                    break
                }
            }
            completion(result)
        })
    }

    /// Unlink the user.
    public static func unlinkClients() {
        if let oAuthManager = DropboxOAuthManager.sharedOAuthManager {
            _ = oAuthManager.clearStoredAccessTokens()
            resetClients()
        }
    }

    /// Unlink the user.
    public static func resetClients() {
        if DropboxClientsManager.authorizedClient == nil && DropboxClientsManager.authorizedTeamClient == nil {
            // already unlinked
            return
        }

        DropboxClientsManager.authorizedClient = nil
        DropboxClientsManager.authorizedTeamClient = nil
    }
}
