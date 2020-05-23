///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation
import Alamofire

/// The client for the Business API. Call routes using the namespaces inside this object (inherited from parent).

open class DropboxTeamClient: DropboxTeamBase {
    private var transportClient: DropboxTransportClient
    private var accessTokenProvider: AccessTokenProvider

    /// Initialize a client with a static accessToken string.
    /// Use this method if your access token is long-lived.
    ///
    /// - Parameter accessToken: Static access token string.
    public convenience init(accessToken: String) {
        let transportClient = DropboxTransportClient(accessToken: accessToken)
        self.init(transportClient: transportClient)
    }

    /// Initialize a client with an `AccessTokenProvider`.
    /// Use this method if your access token is short-lived.
    /// See `ShortLivedAccessTokenProvider` for a default implementation.
    ///
    /// - Parameter accessTokenProvider: Access token provider that wraps a short-lived token and its refresh logic.
    public convenience init(accessTokenProvider: AccessTokenProvider) {
        let transportClient = DropboxTransportClient(accessTokenProvider: accessTokenProvider)
        self.init(transportClient: transportClient)
    }

    /// Designated Initializer.
    ///
    /// - Parameter transportClient: The underlying DropboxTransportClient to make API calls.
    public init(transportClient: DropboxTransportClient) {
        self.transportClient = transportClient
        self.accessTokenProvider = transportClient.accessTokenProvider
        super.init(client: transportClient)
    }

    /// Creates a new DropboxClient instance for the team member id.
    ///
    /// - Parameter memberId: Team member id.
    /// - Returns: A new DropboxClient instance that can be used to call APIs on the team member's behalf.
    public func asMember(_ memberId: String) -> DropboxClient {
        return DropboxClient(accessTokenProvider: accessTokenProvider, selectUser: memberId)
    }
}
