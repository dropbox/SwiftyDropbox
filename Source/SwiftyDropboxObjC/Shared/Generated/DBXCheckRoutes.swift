///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import SwiftyDropbox

/// Objective-C compatible routes for the check namespace
/// For Swift routes see CheckRoutes
@objc
public class DBXCheckRoutes: NSObject {
    private let swift: CheckRoutes
    init(swift: CheckRoutes) {
        self.swift = swift
        self.client = swift.client.objc
    }

    public let client: DBXDropboxTransportClient

    /// This endpoint performs User Authentication, validating the supplied access token, and returns the supplied
    /// string, to allow you to test your code and connection to the Dropbox API. It has no other effect. If you
    /// receive an HTTP 200 response with the supplied query, it indicates at least part of the Dropbox API
    /// infrastructure is working and that the access token is valid.
    ///
    /// - scope: account_info.read
    ///
    /// - parameter query: The string that you'd like to be echoed back to you.
    ///
    /// - returns: Through the response callback, the caller will receive a `Check.EchoResult` object on success or a
    /// `Void` object on failure.
    @objc
    @discardableResult public func user(query: String) -> DBXCheckUserRpcRequest {
        let swift = swift.user(query: query)
        return DBXCheckUserRpcRequest(swift: swift)
    }

    /// This endpoint performs User Authentication, validating the supplied access token, and returns the supplied
    /// string, to allow you to test your code and connection to the Dropbox API. It has no other effect. If you
    /// receive an HTTP 200 response with the supplied query, it indicates at least part of the Dropbox API
    /// infrastructure is working and that the access token is valid.
    ///
    /// - scope: account_info.read
    ///
    /// - returns: Through the response callback, the caller will receive a `Check.EchoResult` object on success or a
    /// `Void` object on failure.
    @objc
    @discardableResult public func user() -> DBXCheckUserRpcRequest {
        let swift = swift.user()
        return DBXCheckUserRpcRequest(swift: swift)
    }
}

@objc
public class DBXCheckUserRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<Check.EchoResultSerializer, VoidSerializer>

    init(swift: RpcRequest<Check.EchoResultSerializer, VoidSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXCheckEchoResult?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXCheckEchoResult?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, analyticsBlock: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue? = nil,
        analyticsBlock: AnalyticsBlock? = nil,
        completionHandler: @escaping (DBXCheckEchoResult?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue, analyticsBlock: analyticsBlock) { result, error in
            var objc: DBXCheckEchoResult?
            if let swift = result {
                objc = DBXCheckEchoResult(swift: swift)
            }
            completionHandler(objc, error?.objc)
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
