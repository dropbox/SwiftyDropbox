///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import SwiftyDropbox

/// Objective-C compatible routes for the contacts namespace
/// For Swift routes see ContactsRoutes
@objc
public class DBXContactsRoutes: NSObject {
    private let swift: ContactsRoutes
    init(swift: ContactsRoutes) {
        self.swift = swift
        self.client = swift.client.objc
    }

    public let client: DBXDropboxTransportClient

    /// Removes all manually added contacts. You'll still keep contacts who are on your team or who you imported. New
    /// contacts will be added when you share.
    ///
    /// - scope: contacts.write
    ///
    ///
    /// - returns: Through the response callback, the caller will receive a `Void` object on success or a `Void` object
    /// on failure.
    @objc
    @discardableResult public func deleteManualContacts() -> DBXContactsDeleteManualContactsRpcRequest {
        let swift = swift.deleteManualContacts()
        return DBXContactsDeleteManualContactsRpcRequest(swift: swift)
    }

    /// Removes manually added contacts from the given list.
    ///
    /// - scope: contacts.write
    ///
    /// - parameter emailAddresses: List of manually added contacts to be deleted.
    ///
    /// - returns: Through the response callback, the caller will receive a `Void` object on success or a
    /// `Contacts.DeleteManualContactsError` object on failure.
    @objc
    @discardableResult public func deleteManualContactsBatch(emailAddresses: [String]) -> DBXContactsDeleteManualContactsBatchRpcRequest {
        let swift = swift.deleteManualContactsBatch(emailAddresses: emailAddresses)
        return DBXContactsDeleteManualContactsBatchRpcRequest(swift: swift)
    }
}

@objc
public class DBXContactsDeleteManualContactsRpcRequest: NSObject, DBXRequest {
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

@objc
public class DBXContactsDeleteManualContactsBatchRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<VoidSerializer, Contacts.DeleteManualContactsErrorSerializer>

    init(swift: RpcRequest<VoidSerializer, Contacts.DeleteManualContactsErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXContactsDeleteManualContactsError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXContactsDeleteManualContactsError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { _, error in
            var routeError: DBXContactsDeleteManualContactsError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXContactsDeleteManualContactsError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            completionHandler(routeError, callError)
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
