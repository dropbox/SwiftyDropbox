///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

@objc
public protocol DBXSharedApplication: AnyObject {
    func presentErrorMessage(_ message: String, title: String)
    func presentErrorMessageWithHandlers(_ message: String, title: String, buttonTitles: [String], buttonHandler: (String) -> Void)
    func presentPlatformSpecificAuth(_ authURL: URL) -> Bool
    func presentAuthChannel(_ authURL: URL, tryIntercept: @escaping ((URL) -> Bool), cancelHandler: @escaping (() -> Void))
    func presentExternalApp(_ url: URL)
    func canPresentExternalApp(_ url: URL) -> Bool
    func presentLoading()
    func dismissLoading()
}

extension DBXSharedApplication {
    var swift: SharedApplication {
        SharedApplicationBridge(objc: self)
    }
}

class SharedApplicationBridge: SharedApplication {
    func presentErrorMessage(_ message: String, title: String) {
        objc.presentErrorMessage(message, title: title)
    }

    func presentErrorMessageWithHandlers(_ message: String, title: String, buttonHandlers: [String: () -> Void]) {
        let buttonHandler: (String) -> Void = { buttonTitle in
            buttonHandlers[buttonTitle]?()
        }
        objc.presentErrorMessageWithHandlers(message, title: title, buttonTitles: buttonHandlers.keys.sorted(), buttonHandler: buttonHandler)
    }

    func presentPlatformSpecificAuth(_ authURL: URL) -> Bool {
        objc.presentPlatformSpecificAuth(authURL)
    }

    func presentAuthChannel(_ authURL: URL, tryIntercept: @escaping ((URL) -> Bool), cancelHandler: @escaping (() -> Void)) {
        objc.presentAuthChannel(authURL, tryIntercept: tryIntercept, cancelHandler: cancelHandler)
    }

    func presentExternalApp(_ url: URL) {
        objc.presentExternalApp(url)
    }

    func canPresentExternalApp(_ url: URL) -> Bool {
        objc.canPresentExternalApp(url)
    }

    func presentLoading() {
        objc.presentLoading()
    }

    func dismissLoading() {
        objc.dismissLoading()
    }

    let objc: DBXSharedApplication

    init(objc: DBXSharedApplication) {
        self.objc = objc
    }
}

@objc public protocol DBXAccessTokenRefreshing {
    /// Refreshes a (short-lived) access token for a given DropboxAccessToken.
    ///
    /// - Parameters:
    ///     - accessToken: A `DropboxAccessToken` object.
    ///     - scopes: An array of scopes to be granted for the refreshed access token.
    ///       The requested scope MUST NOT include any scope not originally granted.
    ///       Useful if users want to reduce the granted scopes for the new access token.
    ///       Pass in an empty array if you don't want to change scopes of the access token.
    ///     - queue: The queue where completion block will be called from.
    ///     - completion: A block to notify caller the result.
    func refreshAccessToken(
        _ accessToken: DBXDropboxAccessToken,
        scopes: [String],
        queue: DispatchQueue?,
        completion: @escaping (DBXDropboxOAuthResult?) -> Void
    )
}

extension DBXAccessTokenRefreshing {
    var swift: AccessTokenRefreshing {
        AccessTokenRefreshingBridge(objc: self)
    }
}

class AccessTokenRefreshingBridge: AccessTokenRefreshing {
    let objc: DBXAccessTokenRefreshing
    init(objc: DBXAccessTokenRefreshing) {
        self.objc = objc
    }

    func refreshAccessToken(
        _ accessToken: DropboxAccessToken,
        scopes: [String],
        queue: DispatchQueue?,
        completion: @escaping DropboxOAuthCompletion
    ) {
        objc.refreshAccessToken(DBXDropboxAccessToken(swift: accessToken), scopes: scopes, queue: queue) { dbresult in
            completion(dbresult?.swift)
        }
    }
}

extension DropboxAccessToken {
    var objc: DBXDropboxAccessToken {
        DBXDropboxAccessToken(swift: self)
    }
}

@objc
public class DBXDropboxAccessToken: NSObject {
    let swift: DropboxAccessToken

    fileprivate init(swift: DropboxAccessToken) {
        self.swift = swift
    }

    /// The access token string.
    @objc
    public var accessToken: String { swift.accessToken }

    /// The associated user id.
    @objc
    public var uid: String { swift.uid }

    /// The refresh token if accessToken is short-lived.
    @objc
    public var refreshToken: String? { swift.refreshToken }

    /// The expiration time of the (short-lived) accessToken.
    @objc
    public var tokenExpirationTimestamp: NSNumber? {
        guard let value = swift.tokenExpirationTimestamp else { return nil }
        return NSNumber(value: value)
    }

    /// Indicates whether the access token is short-lived.
    @objc
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
    @objc
    public init(
        accessToken: String,
        uid: String,
        refreshToken: String? = nil,
        tokenExpirationTimestamp: NSNumber? = nil
    ) {
        self.swift = DropboxAccessToken(
            accessToken: accessToken,
            uid: uid,
            refreshToken: refreshToken,
            tokenExpirationTimestamp: tokenExpirationTimestamp?.doubleValue
        )
    }

    @objc
    open override var description: String {
        swift.description
    }
}

func bridgeDropboxOAuthCompletion(_ completion: @escaping (DBXDropboxOAuthResult?) -> Void) -> DropboxOAuthCompletion {
    {
        if let swift = $0 {
            let dbResult = DBXDropboxOAuthResult(swift: swift)
            completion(dbResult)
        } else {
            completion(nil)
        }
    }
}

extension OAuth2Error {
    var objc: DBXOAuth2Error {
        DBXOAuth2Error(swift: self)
    }
}

@objc
public class DBXOAuth2Error: NSObject {
    let swift: OAuth2Error

    /// Initializes an error code from the string specced in RFC6749
    fileprivate init(swift: OAuth2Error) {
        self.swift = swift
    }

    /// Indicates whether the error is invalid_grant error.
    @objc
    var isInvalidGrantError: Bool { swift.isInvalidGrantError }
}

extension DropboxOAuthResult {
    var objc: DBXDropboxOAuthResult {
        DBXDropboxOAuthResult(swift: self)
    }
}

@objc
public class DBXDropboxOAuthResult: NSObject {
    let swift: DropboxOAuthResult

    fileprivate init(swift: DropboxOAuthResult) {
        self.swift = swift
    }

    @objc
    public var token: DBXDropboxAccessToken? {
        switch swift {
        case .success(let swift):
            return DBXDropboxAccessToken(swift: swift)
        default:
            return nil
        }
    }

    @objc
    public var error: DBXOAuth2Error? {
        switch swift {
        case .error(let swift, _):
            return DBXOAuth2Error(swift: swift)
        default:
            return nil
        }
    }

    @objc
    public var errorMessage: String? {
        switch swift {
        case .error(_, let errorMessage):
            return errorMessage
        default:
            return nil
        }
    }

    @objc
    public var wasCancelled: Bool {
        switch swift {
        case .cancel:
            return true
        default:
            return false
        }
    }
}
