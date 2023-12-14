///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

extension DropboxOAuthManager {
    var objc: DBXDropboxOAuthManager {
        DBXDropboxOAuthManager(swift: self)
    }
}

@objc
public class DBXDropboxOAuthManager: NSObject {
    @objc
    public var locale: Locale? { swift.locale }

    // MARK: Shared instance

    /// A shared instance of a `DropboxOAuthManager` for convenience
    @objc
    public static var sharedOAuthManager: DBXDropboxOAuthManager {
        get {
            DBXDropboxOAuthManager(swift: .sharedOAuthManager)
        }
        set {
            DropboxOAuthManager.sharedOAuthManager = newValue.swift
        }
    }

    let swift: DropboxOAuthManager

    init(swift: DropboxOAuthManager) {
        self.swift = swift
    }

    @objc
    public convenience init(
        appKey: String,
        host: String,
        secureStorageAccess: DBXSecureStorageAccess
    ) {
        let secureStorageAccessBridge = secureStorageAccess.swift
        self.init(swift: DropboxOAuthManager(appKey: appKey, host: host, secureStorageAccess: secureStorageAccessBridge))
    }

    ///
    /// Create an instance
    /// parameter appKey: The app key from the developer console that identifies this app.
    ///
    @objc
    public convenience init(appKey: String, secureStorageAccess: DBXSecureStorageAccess) {
        self.init(appKey: appKey, host: "www.dropbox.com", secureStorageAccess: secureStorageAccess)
    }

    ///
    /// Try to handle a redirect back into the application
    ///
    /// - parameters:
    ///     - url: The URL to attempt to handle.
    ///     - completion: The callback closure to receive auth result.
    /// - returns: Whether the redirect URL can be handled.
    ///
    @objc
    public func handleRedirectURL(_ url: URL, completion: @escaping (DBXDropboxOAuthResult?) -> Void) -> Bool {
        swift.handleRedirectURL(url, completion: bridgeDropboxOAuthCompletion(completion))
    }

    ///
    /// Present the OAuth2 authorization request page by presenting a web view controller modally.
    ///
    /// - parameters:
    ///     - sharedApplication: The application to present from.
    ///     - usePKCE: Whether to use OAuth2 code flow with PKCE. Default is false, i.e. use the legacy token flow.
    ///     - scopeRequest: The ScopeRequest, only used in code flow with PKCE.
    @objc
    public func authorizeFromSharedApplication(
        _ sharedApplication: DBXSharedApplication, usePKCE: Bool = false, scopeRequest: DBXScopeRequest? = nil
    ) {
        swift.authorizeFromSharedApplication(sharedApplication.swift, usePKCE: usePKCE, scopeRequest: scopeRequest?.swift)
    }

    ///
    /// Retrieve all stored access tokens
    ///
    /// - returns: a dictionary mapping users to their access tokens
    ///
    @objc
    public func getAllAccessTokens() -> [String: DBXDropboxAccessToken] {
        swift.getAllAccessTokens().mapValues { $0.objc }
    }

    ///
    /// Check if there are any stored access tokens
    ///
    /// - returns: Whether there are stored access tokens
    ///
    @objc
    public func hasStoredAccessTokens() -> Bool {
        swift.hasStoredAccessTokens()
    }

    ///
    /// Retrieve the access token for a particular user
    ///
    /// - parameter user: The user whose token to retrieve
    ///
    /// - returns: An access token if present, otherwise `nil`.
    ///
    @objc
    public func getAccessToken(_ user: String?) -> DBXDropboxAccessToken? {
        swift.getAccessToken(user)?.objc
    }

    ///
    /// Delete a specific access token
    ///
    /// - parameter token: The access token to delete
    ///
    /// - returns: whether the operation succeeded
    ///
    @objc
    public func clearStoredAccessToken(_ token: DBXDropboxAccessToken) -> Bool {
        swift.clearStoredAccessToken(token.swift)
    }

    ///
    /// Delete all stored access tokens
    ///
    /// - returns: whether the operation succeeded
    ///
    @objc
    public func clearStoredAccessTokens() -> Bool {
        swift.clearStoredAccessTokens()
    }

    ///
    /// Save an access token
    ///
    /// - parameter token: The access token to save
    ///
    /// - returns: whether the operation succeeded
    ///
    @objc
    @discardableResult
    public func storeAccessToken(_ token: DBXDropboxAccessToken) -> Bool {
        swift.storeAccessToken(token.swift)
    }

    ///
    /// Utility function to return an arbitrary access token
    ///
    /// - returns: the "first" access token found, if any (otherwise `nil`)
    ///
    @objc
    public func getFirstAccessToken() -> DBXDropboxAccessToken? {
        swift.getFirstAccessToken()?.objc
    }

    // MARK: Short-lived token support.

    /// Refreshes a (short-lived) access token for a given DropboxAccessToken.
    ///
    /// - Parameters:
    ///     - accessToken: A `DropboxAccessToken` object.
    ///     - scopes: An array of scopes to be granted for the refreshed access token.
    ///       The requested scope MUST NOT include any scope not originally granted.
    ///       Useful if users want to reduce the granted scopes for the new access token.
    ///       Pass in an empty array if you don't want to change scopes of the access token.
    ///     - queue: The queue where completion block will be called from.
    ///     - completion: A `DropboxOAuthCompletion` block to notify caller the result.
    ///
    /// - NOTE: Completion block will be called on main queue if a callback queue is not provided.
    @objc
    public func refreshAccessToken(
        _ accessToken: DBXDropboxAccessToken,
        scopes: [String],
        queue: DispatchQueue?,
        completion: @escaping (DBXDropboxOAuthResult?) -> Void
    ) {
        swift.refreshAccessToken(accessToken.swift, scopes: scopes, queue: queue, completion: bridgeDropboxOAuthCompletion(completion))
    }

    /// Creates an `AccessTokenProvider` that wraps short-lived for token refresh
    /// or a static provider for long-live token.
    /// - Parameter token: The `DropboxAccessToken` object.
    @objc
    public func accessTokenProviderForToken(_ token: DBXDropboxAccessToken) -> DBXAccessTokenProvider {
        swift.accessTokenProviderForToken(token.swift).objc
    }
}
