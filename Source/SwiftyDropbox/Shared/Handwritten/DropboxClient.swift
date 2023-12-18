///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation

/// The client for the User API. Call routes using the namespaces inside this object (inherited from parent).

public class DropboxClient: DropboxBase {
    public let accessTokenProvider: AccessTokenProvider
    public private(set) var selectUser: String?
    public var identifier: String? {
        client.identifier
    }

    /// Initialize a client with a static accessToken string.
    /// Use this method if your access token is long-lived.
    ///
    /// - Parameters:
    ///     - accessToken: Static access token string.
    ///     - selectUser: Id of a team member. This allows the api client to makes call on a team member's behalf.
    ///     - sessionConfiguration: Optional custom network session configuration
    ///     - pathRoot: User's path root.
    public convenience init(
        accessToken: String,
        selectUser: String? = nil,
        sessionConfiguration: NetworkSessionConfiguration? = nil,
        pathRoot: Common.PathRoot? = nil
    ) {
        let transportClient = DropboxTransportClientImpl(
            accessToken: accessToken,
            selectUser: selectUser,
            sessionConfiguration: sessionConfiguration,
            pathRoot: pathRoot
        )
        self.init(transportClient: transportClient)
    }

    /// Initialize a client with an `AccessTokenProvider`.
    /// Use this method if your access token is short-lived.
    /// See `ShortLivedAccessTokenProvider` for a default implementation.
    ///
    /// - Parameters:
    ///     - accessTokenProvider: Access token provider that wraps a short-lived token and its refresh logic.
    ///     - selectUser: Id of a team member. This allows the api client to makes call on a team member's behalf.
    ///     - sessionConfiguration: Optional custom network session configuration
    ///     - pathRoot: User's path root.
    public convenience init(
        accessTokenProvider: AccessTokenProvider,
        selectUser: String? = nil,
        sessionConfiguration: NetworkSessionConfiguration? = nil,
        pathRoot: Common.PathRoot? = nil
    ) {
        let transportClient = DropboxTransportClientImpl(
            accessTokenProvider: accessTokenProvider, selectUser: selectUser, sessionConfiguration: sessionConfiguration, pathRoot: pathRoot
        )
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
        self.selectUser = transportClient.selectUser
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

    /// Creates a new DropboxClient instance with the given path root.
    ///
    /// - Parameter pathRoot: User's path root.
    /// - Returns: A new DropboxClient instance for the same user but with an updated path root.
    public func withPathRoot(_ pathRoot: Common.PathRoot) -> DropboxClient {
        DropboxClient(accessTokenProvider: accessTokenProvider, selectUser: selectUser, pathRoot: pathRoot)
    }

    public var didFinishBackgroundEvents: (() -> Void)? {
        set {
            client.didFinishBackgroundEvents = newValue
        }
        get {
            client.didFinishBackgroundEvents
        }
    }

    /// Fetches completed and running background tasks to be reconnected
    ///
    /// - Parameter completion: The callback closure to recieve the reconnected requests or errors
    public func getAllRequests(completion: @escaping ([Result<DropboxBaseRequestBox, ReconnectionError>]) -> Void) {
        guard let client = client as? DropboxTransportClientImpl else {
            DropboxClientsManager.logBackgroundSession(.error, "background sessions only supported on DropboxTransportClientImpl")
            fatalError("background sessions only supported on DropboxTransportClientImpl")
        }

        client.manager.getAllTasks { apiRequests in
            DropboxClientsManager.logBackgroundSession("getAllRequests transport client returned requests \(apiRequests.count)")

            let requests: [Result<DropboxBaseRequestBox, ReconnectionError>] = apiRequests.map { apiRequest in
                do {
                    let request = try ReconnectionHelpers.rebuildRequest(apiRequest: apiRequest, client: client)
                    DropboxClientsManager.logBackgroundSession("getAllRequests reconstitute success \(apiRequest.identifier)")
                    return .success(request)
                } catch {
                    DropboxClientsManager.logBackgroundSession(.error, "getAllRequests reconstitute error \(error)")
                    return .failure(ReconnectionError(
                        reconnectionErrorKind: (error as? ReconnectionErrorKind) ?? .unknown,
                        taskDescription: apiRequest.taskDescription
                    ))
                }
            }

            completion(requests)
        }
    }

    /// Cancels all tasks and invalidates all network sessions
    public func shutdown() {
        client.shutdown()
    }
}
