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
public class DropboxClientsManager {
    /// An authorized client. This will be set to nil if unlinked.
    public static var authorizedClient: DropboxClient?

    /// An authorized team client. This will be set to nil if unlinked.
    public static var authorizedTeamClient: DropboxTeamClient?

    /// Sets up access to the Dropbox User API
    static func setupWithOAuthManager(_ appKey: String, oAuthManager: DropboxOAuthManager, transportClient: DropboxTransportClient?) {
        precondition(DropboxOAuthManager.sharedAuthManager == nil, "Only call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` once")
        DropboxOAuthManager.sharedAuthManager = oAuthManager

        if let token = DropboxOAuthManager.sharedAuthManager.getFirstAccessToken() {
            setupAuthorizedClient(token, transportClient:transportClient)
        }
    }

    /// Sets up access to the Dropbox User API
    static func setupWithOAuthManagerMultiUser(_ appKey: String, oAuthManager: DropboxOAuthManager, transportClient: DropboxTransportClient?, tokenUid: String?) {
        precondition(DropboxOAuthManager.sharedAuthManager == nil, "Only call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` once")
        DropboxOAuthManager.sharedAuthManager = oAuthManager
        
        if let token = DropboxOAuthManager.sharedAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedClient(token, transportClient:transportClient)
        }
    }
    
    /// Sets up access to the Dropbox Business (Team) API
    static func setupWithOAuthManagerTeam(_ appKey: String, oAuthManager: DropboxOAuthManager, transportClient: DropboxTransportClient?) {
        precondition(DropboxOAuthManager.sharedAuthManager == nil, "Only call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` once")
        DropboxOAuthManager.sharedAuthManager = oAuthManager
        
        if let token = DropboxOAuthManager.sharedAuthManager.getFirstAccessToken() {
            setupAuthorizedTeamClient(token, transportClient:transportClient)
        }
    }
    
    /// Sets up access to the Dropbox Business (Team) API in multi-user case
    static func setupWithOAuthManagerMultiUserTeam(_ appKey: String, oAuthManager: DropboxOAuthManager, transportClient: DropboxTransportClient?, tokenUid: String?) {
        precondition(DropboxOAuthManager.sharedAuthManager == nil, "Only call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` once")
        DropboxOAuthManager.sharedAuthManager = oAuthManager
        
        if let token = DropboxOAuthManager.sharedAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedTeamClient(token, transportClient:transportClient)
        }
    }
    
    public static func reauthorizeClient(tokenUid: String) {
        precondition(DropboxOAuthManager.sharedAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")
        precondition(DropboxClientsManager.authorizedClient == nil, "Dropbox user client is already authorized")
        
        if let token = DropboxOAuthManager.sharedAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedClient(token, transportClient:nil)
        }
    }
    
    public static func reauthorizeTeamClient(tokenUid: String) {
        precondition(DropboxOAuthManager.sharedAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")
        precondition(DropboxClientsManager.authorizedClient == nil, "Dropbox user client is already authorized")
        
        if let token = DropboxOAuthManager.sharedAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedTeamClient(token, transportClient:nil)
        }
    }
    
    static func setupAuthorizedClient(_ accessToken: DropboxAccessToken?, transportClient: DropboxTransportClient?) {
        if let accessToken = accessToken {
            if let transportClient = transportClient {
                transportClient.accessToken = accessToken.accessToken
                authorizedClient = DropboxClient(transportClient: transportClient)
            } else {
                authorizedClient = DropboxClient(accessToken: accessToken.accessToken)
            }
        } else {
            if let transportClient = transportClient {
                authorizedClient = DropboxClient(transportClient: transportClient)
            }
        }
    }
    
    static func setupAuthorizedTeamClient(_ accessToken: DropboxAccessToken?, transportClient: DropboxTransportClient?) {
        if let accessToken = accessToken {
            if let transportClient = transportClient {
                transportClient.accessToken = accessToken.accessToken
                authorizedTeamClient = DropboxTeamClient(transportClient: transportClient)
            } else {
                authorizedTeamClient = DropboxTeamClient(accessToken: accessToken.accessToken)
            }
        } else {
            if let transportClient = transportClient {
                authorizedTeamClient = DropboxTeamClient(transportClient: transportClient)
            }
        }
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    public static func handleRedirectURL(_ url: URL) -> DropboxOAuthResult? {
        precondition(DropboxOAuthManager.sharedAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")
        precondition(DropboxClientsManager.authorizedClient == nil, "Dropbox user client is already authorized")
        if let result =  DropboxOAuthManager.sharedAuthManager.handleRedirectURL(url) {
            switch result {
            case .success(let accessToken):
                DropboxClientsManager.authorizedClient = DropboxClient(accessToken: accessToken.accessToken)
                return result
            case .cancel:
                return result
            case .error:
                return result
            }
        } else {
            return nil
        }
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    public static func handleRedirectURLTeam(_ url: URL) -> DropboxOAuthResult? {
        precondition(DropboxOAuthManager.sharedAuthManager != nil, "Call `DropboxClientsManager.setupWithTeamAppKey` before calling this method")
        precondition(DropboxClientsManager.authorizedTeamClient == nil, "Dropbox team client is already authorized")
        if let result =  DropboxOAuthManager.sharedAuthManager.handleRedirectURL(url) {
            switch result {
            case .success(let accessToken):
                DropboxClientsManager.authorizedTeamClient = DropboxTeamClient(accessToken: accessToken.accessToken)
                return result
            case .cancel:
                return result
            case .error:
                return result
            }
        } else {
            return nil
        }
    }

    /// Unlink the user.
    public static func unlinkClient() {
        precondition(DropboxOAuthManager.sharedAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")
        
        _ = DropboxOAuthManager.sharedAuthManager.clearStoredAccessTokens()
        resetClients()
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
