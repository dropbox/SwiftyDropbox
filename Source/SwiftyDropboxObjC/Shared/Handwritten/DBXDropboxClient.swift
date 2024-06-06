///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

extension DropboxClient {
    var objc: DBXDropboxClient {
        DBXDropboxClient(swift: self)
    }
}

/// The client for the User API. Call routes using the namespaces inside this object (inherited from parent).
@objc
public class DBXDropboxClient: DBXDropboxBase {
    let subSwift: DropboxClient

    /// Initialize a client from swift using an existing Swift client.
    ///
    /// - Parameter swift: The underlying DropboxClient to make API calls.
    public init(swift: DropboxClient) {
        self.subSwift = swift
        super.init(swiftClient: swift.client)
    }

    /// Initialize a client with a static accessToken string.
    /// Use this method if your access token is long-lived.
    ///
    /// - Parameters:
    ///     - accessToken: Static access token string.
    ///     - selectUser: Id of a team member. This allows the api client to makes call on a team member's behalf.
    ///     - sessionConfiguration: Optional custom network session configuration
    ///     - pathRoot: User's path root.
    @objc
    public convenience init(
        accessToken: String,
        selectUser: String? = nil,
        sessionConfiguration: DBXNetworkSessionConfiguration? = nil,
        pathRoot: DBXCommonPathRoot? = nil
    ) {
        let transportClient = DBXDropboxTransportClient(
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
    @objc
    public convenience init(
        accessTokenProvider: DBXAccessTokenProvider,
        selectUser: String? = nil,
        sessionConfiguration: DBXNetworkSessionConfiguration? = nil,
        pathRoot: DBXCommonPathRoot? = nil
    ) {
        let transportClient = DBXDropboxTransportClient(
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
    @objc
    public convenience init(
        accessToken: DBXDropboxAccessToken,
        dropboxOauthManager: DBXDropboxOAuthManager,
        sessionConfiguration: DBXNetworkSessionConfiguration? = nil
    ) {
        let accessTokenProvider = dropboxOauthManager.accessTokenProviderForToken(accessToken)
        let transportClient = DBXDropboxTransportClient(accessTokenProvider: accessTokenProvider, sessionConfiguration: sessionConfiguration)
        self.init(transportClient: transportClient)
    }

    /// Designated Initializer.
    ///
    /// - Parameter transportClient: The underlying DropboxTransportClient to make API calls.
    @objc
    public convenience init(transportClient: DBXDropboxTransportClient) {
        self.init(swift: DropboxClient(transportClient: transportClient.swift))
    }

    /// Creates a new DropboxClient instance with the given path root.
    ///
    /// - Parameter pathRoot: User's path root.
    /// - Returns: A new DropboxClient instance for the same user but with an updated path root.
    @objc
    public func withPathRoot(_ pathRoot: DBXCommonPathRoot) -> DBXDropboxClient {
        guard let accessTokenProvider = swift.client.accessTokenProvider else {
            fatalError("Attempting to copy a app auth client using a path root")
        }

        return DBXDropboxClient(accessTokenProvider: accessTokenProvider.objc, selectUser: swift.client.selectUser, pathRoot: pathRoot)
    }

    @objc
    public var didFinishBackgroundEvents: (() -> Void)? {
        set {
            swift.client.didFinishBackgroundEvents = newValue
        }
        get {
            swift.client.didFinishBackgroundEvents
        }
    }

    /// Fetches completed and running background tasks to be reconnected
    ///
    /// - Parameter completion: The callback closure to recieve the reconnected requests or errors
    @objc
    public func getAllRequests(completion: @escaping ([DBXReconnectionResult]) -> Void) {
        subSwift.getAllRequests { swifts in
            let objcs = swifts.map { swift in
                switch swift {
                case .success(let box):
                    return DBXReconnectionResult(request: box.objc, error: nil)
                case .failure(let error):
                    return DBXReconnectionResult(request: nil, error: error.objc)
                }
            }
            completion(objcs)
        }
    }

    /// Cancels all tasks and invalidates all network sessions
    @objc
    public func shutdown() {
        subSwift.shutdown()
    }
}
