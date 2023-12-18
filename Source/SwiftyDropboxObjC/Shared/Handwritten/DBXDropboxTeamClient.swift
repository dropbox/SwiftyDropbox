///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

/// The client for the Business API. Call routes using the namespaces inside this object (inherited from parent).

extension DropboxTeamClient {
    var objc: DBXDropboxTeamClient {
        DBXDropboxTeamClient(swift: self)
    }
}

@objc
public class DBXDropboxTeamClient: DBXDropboxTeamBase {
    let subSwift: DropboxTeamClient

    fileprivate init(swift: DropboxTeamClient) {
        self.subSwift = swift
        super.init(swiftClient: swift.client)
    }

    /// Initialize a client with a static accessToken string.
    /// Use this method if your access token is long-lived.
    ///
    /// - Parameters:
    ///     - accessToken: Static access token string.
    ///     - sessionConfiguration: Optional custom network session configuration
    ///
    @objc
    public convenience init(
        accessToken: String,
        sessionConfiguration: DBXNetworkSessionConfiguration? = nil
    ) {
        let transportClient = DBXDropboxTransportClient(accessToken: accessToken)
        self.init(transportClient: transportClient)
    }

    /// Initialize a client with an `AccessTokenProvider`.
    /// Use this method if your access token is short-lived.
    /// See `ShortLivedAccessTokenProvider` for a default implementation.
    ///
    /// - Parameter accessTokenProvider: Access token provider that wraps a short-lived token and its refresh logic.
    @objc
    public convenience init(
        accessTokenProvider: DBXAccessTokenProvider,
        sessionConfiguration: DBXNetworkSessionConfiguration? = nil
    ) {
        let transportClient = DBXDropboxTransportClient(accessTokenProvider: accessTokenProvider)
        self.init(transportClient: transportClient)
    }

    /// Initialize a client with an `DropboxAccessToken`.
    ///
    /// - Parameters:
    ///     - accessToken: The token itself, could be long or short lived.
    ///     - dropboxOauthManager: an oauthManager, used for creating the token provider.
    ///     - sessionConfiguration: Optional custom network session configuration
    @objc
    public convenience init(
        accessToken: DBXDropboxAccessToken,
        dropboxOauthManager: DBXDropboxOAuthManager,
        sessionConfiguration: DBXNetworkSessionConfiguration? = nil
    ) {
        let accessTokenProvider = dropboxOauthManager.accessTokenProviderForToken(accessToken)
        let transportClient = DBXDropboxTransportClient(accessTokenProvider: accessTokenProvider)
        self.init(transportClient: transportClient)
    }

    /// Designated Initializer.
    ///
    /// - Parameter transportClient: The underlying DropboxTransportClient to make API calls.
    @objc
    public convenience init(transportClient: DBXDropboxTransportClient) {
        self.init(swift: DropboxTeamClient(transportClient: transportClient.swift))
    }

    /// Creates a new DropboxClient instance for the team member id.
    ///
    /// - Parameter memberId: Team member id.
    /// - Returns: A new DropboxClient instance that can be used to call APIs on the team member's behalf.
    @objc
    public func asMember(_ memberId: String) -> DBXDropboxClient {
        DropboxClient(accessTokenProvider: subSwift.accessTokenProvider, selectUser: memberId).objc
    }
}
