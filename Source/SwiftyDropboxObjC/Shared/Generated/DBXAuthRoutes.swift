///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import SwiftyDropbox

/// Objective-C compatible routes for the auth namespace
/// For Swift routes see AuthRoutes
@objc
public class DBXAuthRoutes: NSObject {
    private let swift: AuthRoutes
    init(swift: AuthRoutes) {
        self.swift = swift
        self.client = swift.client.objc
    }

    public let client: DBXDropboxTransportClient

    /// Disables the access token used to authenticate the call. If there is a corresponding refresh token for the
    /// access token, this disables that refresh token, as well as any other access tokens for that refresh token.
    ///
    ///
    /// - returns: Through the response callback, the caller will receive a `Void` object on success or a `Void` object
    /// on failure.
    @objc
    @discardableResult public func tokenRevoke() -> DBXAuthTokenRevokeRpcRequest {
        let swift = swift.tokenRevoke()
        return DBXAuthTokenRevokeRpcRequest(swift: swift)
    }
}

@objc
public class DBXAuthTokenRevokeRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<VoidSerializer, VoidSerializer>

    init(swift: RpcRequest<VoidSerializer, VoidSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { _, error in
            completionHandler(error?.objc)
        }
        return self
    }

    @objc
    public var clientPersistedString: String? { swift.clientPersistedString }

    @available(iOS 13.0, macOS 10.13, *)
    @objc
    public var earliestBeginDate: Date? { swift.earliestBeginDate }

    @objc
    public func persistingString(string: String?) -> Self {
        swift.persistingString(string: string)
        return self
    }

    @available(iOS 13.0, macOS 10.13, *)
    @objc
    public func settingEarliestBeginDate(date: Date?) -> Self {
        swift.settingEarliestBeginDate(date: date)
        return self
    }

    @objc
    public func cancel() {
        swift.cancel()
    }
}
