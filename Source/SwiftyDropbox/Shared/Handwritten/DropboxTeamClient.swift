///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation

/// The client for the Business API. Call routes using the namespaces inside this object (inherited from parent).

public class DropboxTeamClient: DropboxTeamBase {
    public let accessTokenProvider: AccessTokenProvider

    /// Initialize a client with a static accessToken string.
    /// Use this method if your access token is long-lived.
    ///
    /// - Parameter accessToken: Static access token string.
    public convenience init(accessToken: String) {
        let transportClient = DropboxTransportClientImpl(accessToken: accessToken)
        self.init(transportClient: transportClient)
    }

    /// Initialize a client with an `AccessTokenProvider`.
    /// Use this method if your access token is short-lived.
    /// See `ShortLivedAccessTokenProvider` for a default implementation.
    ///
    /// - Parameters:
    ///     - accessTokenProvider: Access token provider that wraps a short-lived token and its refresh logic.
    ///     - sessionConfiguration: Optional custom network session configuration
    public convenience init(
        accessTokenProvider: AccessTokenProvider,
        sessionConfiguration: NetworkSessionConfiguration? = nil
    ) {
        let transportClient = DropboxTransportClientImpl(accessTokenProvider: accessTokenProvider, sessionConfiguration: sessionConfiguration)
        self.init(transportClient: transportClient)
    }

    /// Initialize a client with an `DropboxAccessToken`.
    ///
    /// - Parameters:
    ///     - accessToken: The token itself, could be long or short lived.
    ///     - dropboxOauthManager: an oauthManager, used for creating the token provider.
    ///     - sessionConfiguration: Optional custom network session configuration
    public convenience init(
        accessToken: DropboxAccessToken,
        dropboxOauthManager: DropboxOAuthManager,
        sessionConfiguration: NetworkSessionConfiguration? = nil
    ) {
        let accessTokenProvider = dropboxOauthManager.accessTokenProviderForToken(accessToken)
        let transportClient = DropboxTransportClientImpl(accessTokenProvider: accessTokenProvider, sessionConfiguration: sessionConfiguration)
        self.init(transportClient: transportClient)
    }

    /// Designated Initializer.
    ///
    /// - Parameter transportClient: The underlying DropboxTransportClient to make API calls.
    public init(transportClient: DropboxTransportClient) {
        guard let accessTokenProvider = transportClient.accessTokenProvider else {
            fatalError("misconfigured user auth transport client")
        }
        self.accessTokenProvider = accessTokenProvider
        super.init(client: transportClient)
    }

    /// Initializer used by DropboxTransportClientOwning in tests.
    ///
    /// - Parameter client: The underlying DropboxTransportClient to make API calls.
    required convenience init(client: DropboxTransportClient) {
        self.init(transportClient: client)
    }

    /// Creates a new DropboxClient instance for the team member id.
    ///
    /// - Parameter memberId: Team member id.
    /// - Returns: A new DropboxClient instance that can be used to call APIs on the team member's behalf.
    public func asMember(_ memberId: String) -> DropboxClient {
        DropboxClient(accessTokenProvider: accessTokenProvider, selectUser: memberId)
    }
}
