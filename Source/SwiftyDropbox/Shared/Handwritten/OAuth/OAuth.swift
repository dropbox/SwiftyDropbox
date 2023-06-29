///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation

public protocol SharedApplication: AnyObject {
    func presentErrorMessage(_ message: String, title: String)
    func presentErrorMessageWithHandlers(_ message: String, title: String, buttonHandlers: [String: () -> Void])
    func presentPlatformSpecificAuth(_ authURL: URL) -> Bool
    func presentAuthChannel(_ authURL: URL, tryIntercept: @escaping ((URL) -> Bool), cancelHandler: @escaping (() -> Void))
    func presentExternalApp(_ url: URL)
    func canPresentExternalApp(_ url: URL) -> Bool
    func presentLoading()
    func dismissLoading()
}

public protocol AccessTokenRefreshing {
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
    func refreshAccessToken(
        _ accessToken: DropboxAccessToken,
        scopes: [String],
        queue: DispatchQueue?,
        completion: @escaping DropboxOAuthCompletion
    )
}

/// Protocol for handling loading status during auth flow.
/// Implementing class could show custom UX to reflect loading status.
@objc(DBXLoadingStatusDelegate)
public protocol LoadingStatusDelegate: AnyObject {
    // Called when auth flow is loading/waiting for some data. e.g. Waiting for a network request to finish.
    func showLoading()
    // Called when auth flow finishes loading/waiting. e.g. A network request finished.
    func dismissLoading()
}

/// Callback block for oauth result.
public typealias DropboxOAuthCompletion = (DropboxOAuthResult?) -> Void

// MARK: - DropboxAccessToken

/// A Dropbox access token
public class DropboxAccessToken: CustomStringConvertible, Codable {
    /// The access token string.
    public let accessToken: String

    /// The associated user id.
    public let uid: String

    /// The refresh token if accessToken is short-lived.
    public let refreshToken: String?

    /// The expiration time of the (short-lived) accessToken.
    public let tokenExpirationTimestamp: TimeInterval?

    /// Indicates whether the access token is short-lived.
    var isShortLivedToken: Bool {
        refreshToken != nil && tokenExpirationTimestamp != nil
    }

    /// Designated Initializer
    ///
    /// - parameters:
    ///     - accessToken: The access token string.
    ///     - uid: The associated user id.
    ///     - refreshToken: The refresh token if accessToken is short-lived.
    ///     - tokenExpirationTimestamp: The expiration time of the (short-lived) accessToken.
    public init(
        accessToken: String, uid: String,
        refreshToken: String? = nil, tokenExpirationTimestamp: TimeInterval? = nil
    ) {
        self.accessToken = accessToken
        self.uid = uid
        self.refreshToken = refreshToken
        self.tokenExpirationTimestamp = tokenExpirationTimestamp
    }

    public var description: String {
        accessToken
    }
}

extension DropboxAccessToken: Equatable {
    public static func == (lhs: DropboxAccessToken, rhs: DropboxAccessToken) -> Bool {
        lhs.accessToken == rhs.accessToken
            && lhs.uid == rhs.uid
            && lhs.refreshToken == rhs.refreshToken
            && lhs.tokenExpirationTimestamp == rhs.tokenExpirationTimestamp
    }
}

/// A failed authorization.
/// Includes errors from both Implicit Grant (See RFC6749 4.2.2.1) and Extension Grants (See RFC6749 5.2),
/// and a couple of SDK defined errors outside of OAuth2 specification.
public enum OAuth2Error: String, Error {
    /// The client is not authorized to request an access token using this method.
    case unauthorizedClient = "unauthorized_client"

    /// The resource owner or authorization server denied the request.
    case accessDenied = "access_denied"

    /// The authorization server does not support obtaining an access token using this method.
    case unsupportedResponseType = "unsupported_response_type"

    /// The requested scope is invalid, unknown, or malformed.
    case invalidScope = "invalid_scope"

    /// The authorization server encountered an unexpected condition that prevented it from fulfilling the request.
    case serverError = "server_error"

    /// The authorization server is currently unable to handle the request due to a temporary overloading or maintenance of the server.
    case temporarilyUnavailable = "temporarily_unavailable"

    /// The request is missing a required parameter, includes an unsupported parameter value (other than grant type),
    /// repeats a parameter, includes multiple credentials, utilizes more than one mechanism for authenticating the
    /// client, or is otherwise malformed.
    case invalidRequest = "invalid_request"

    /// Client authentication failed (e.g., unknown client, no client authentication included, or unsupported
    /// authentication method).
    case invalidClient = "invalid_client"

    /// The provided authorization grant (e.g., authorization code, resource owner credentials) or refresh token is
    /// invalid, expired, revoked, does not match the redirection URI used in the authorization request,
    /// or was issued to another client.
    case invalidGrant = "invalid_grant"

    /// The authorization grant type is not supported by the authorization server.
    case unsupportedGrantType = "unsupported_grant_type"

    /// The state param received from the authorization server does not match the state param stored by the SDK.
    case inconsistentState = "inconsistent_state"

    /// Some other error (outside of the OAuth2 specification)
    case unknown

    /// Initializes an error code from the string specced in RFC6749
    init(errorCode: String) {
        self = Self(rawValue: errorCode) ?? .unknown
    }

    /// Indicates whether the error is invalid_grant error.
    public var isInvalidGrantError: Bool {
        if case .invalidGrant = self {
            return true
        } else {
            return false
        }
    }
}

internal let kDBLinkNonce = "dropbox.sync.nonce"

/// The result of an authorization attempt.
public enum DropboxOAuthResult: Equatable {
    /// The authorization succeeded. Includes a `DropboxAccessToken`.
    case success(DropboxAccessToken)

    /// The authorization failed. Includes an `OAuth2Error` and a descriptive message.
    case error(OAuth2Error, String?)

    /// The authorization was manually canceled by the user.
    case cancel
}
