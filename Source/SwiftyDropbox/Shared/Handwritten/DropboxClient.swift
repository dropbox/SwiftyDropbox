///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation
import Alamofire

/// The client for the User API. Call routes using the namespaces inside this object (inherited from parent).

open class DropboxClient: DropboxBase {
    private var transportClient: DropboxTransportClient
    private var accessTokenProvider: AccessTokenProvider
    private var selectUser: String?

    /// Initialize a client with a static accessToken string.
    /// Use this method if your access token is long-lived.
    ///
    /// - Parameters:
    ///     - accessToken: Static access token string.
    ///     - selectUser: Id of a team member. This allows the api client to makes call on a team member's behalf.
    ///     - pathRoot: User's path root.
    public convenience init(accessToken: String, selectUser: String? = nil, pathRoot: Common.PathRoot? = nil) {
        let transportClient = DropboxTransportClient(accessToken: accessToken, selectUser: selectUser, pathRoot: pathRoot)
        self.init(transportClient: transportClient)
    }

    /// Initialize a client with an `AccessTokenProvider`.
    /// Use this method if your access token is short-lived.
    /// See `ShortLivedAccessTokenProvider` for a default implementation.
    ///
    /// - Parameters:
    ///     - accessTokenProvider: Access token provider that wraps a short-lived token and its refresh logic.
    ///     - selectUser: Id of a team member. This allows the api client to makes call on a team member's behalf.
    ///     - pathRoot: User's path root.
    public convenience init(
        accessTokenProvider: AccessTokenProvider, selectUser: String? = nil, pathRoot: Common.PathRoot? = nil
    ) {
        let transportClient = DropboxTransportClient(
            accessTokenProvider: accessTokenProvider, selectUser: selectUser, pathRoot: pathRoot
        )
        self.init(transportClient: transportClient)
    }

    /// Designated Initializer.
    ///
    /// - Parameter transportClient: The underlying DropboxTransportClient to make API calls.
    public init(transportClient: DropboxTransportClient) {
        self.transportClient = transportClient
        self.selectUser = transportClient.selectUser
        self.accessTokenProvider = transportClient.accessTokenProvider
        super.init(client: transportClient)
    }

    /// Creates a new DropboxClient instance with the given path root.
    ///
    /// - Parameter pathRoot: User's path root.
    /// - Returns: A new DropboxClient instance for the same user but with an updated path root.
    open func withPathRoot(_ pathRoot: Common.PathRoot) -> DropboxClient {
        return DropboxClient(accessTokenProvider: accessTokenProvider, selectUser: selectUser, pathRoot: pathRoot)
    }
}
