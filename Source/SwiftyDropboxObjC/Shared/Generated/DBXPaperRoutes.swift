///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import SwiftyDropbox

/// Objective-C compatible routes for the paper namespace
/// For Swift routes see PaperRoutes
@objc
public class DBXPaperRoutes: NSObject {
    private let swift: PaperRoutes
    init(swift: PaperRoutes) {
        self.swift = swift
        self.client = swift.client.objc
    }

    public let client: DBXDropboxTransportClient
}

@objc
public class DBXPaperDocsArchiveRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<VoidSerializer, Paper.DocLookupErrorSerializer>

    init(swift: RpcRequest<VoidSerializer, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { _, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
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

@objc
public class DBXPaperDocsCreateUploadRequest: NSObject, DBXRequest {
    var swift: UploadRequest<Paper.PaperDocCreateUpdateResultSerializer, Paper.PaperDocCreateErrorSerializer>

    init(swift: UploadRequest<Paper.PaperDocCreateUpdateResultSerializer, Paper.PaperDocCreateErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperPaperDocCreateUpdateResult?, DBXPaperPaperDocCreateError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperPaperDocCreateUpdateResult?, DBXPaperPaperDocCreateError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperPaperDocCreateError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperPaperDocCreateError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperPaperDocCreateUpdateResult?
            if let swift = result {
                objc = DBXPaperPaperDocCreateUpdateResult(swift: swift)
            }
            completionHandler(objc, routeError, callError)
        }
        return self
    }

    @objc
    public func progress(_ progressHandler: @escaping ((Progress) -> Void)) -> Self {
        swift.progress(progressHandler)
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
public class DBXPaperDocsDownloadDownloadRequestFile: NSObject, DBXRequest {
    var swift: DownloadRequestFile<Paper.PaperDocExportResultSerializer, Paper.DocLookupErrorSerializer>

    init(swift: DownloadRequestFile<Paper.PaperDocExportResultSerializer, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperPaperDocExportResult?, URL?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperPaperDocExportResult?, URL?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperPaperDocExportResult?
            var destination: URL?
            if let swift = result {
                objc = DBXPaperPaperDocExportResult(swift: swift.0)
                destination = swift.1
            }
            completionHandler(objc, destination, routeError, callError)
        }
        return self
    }

    @objc
    public func progress(_ progressHandler: @escaping ((Progress) -> Void)) -> Self {
        swift.progress(progressHandler)
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
public class DBXPaperDocsDownloadDownloadRequestMemory: NSObject, DBXRequest {
    var swift: DownloadRequestMemory<Paper.PaperDocExportResultSerializer, Paper.DocLookupErrorSerializer>

    init(swift: DownloadRequestMemory<Paper.PaperDocExportResultSerializer, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperPaperDocExportResult?, Data?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperPaperDocExportResult?, Data?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperPaperDocExportResult?
            var destination: Data?
            if let swift = result {
                objc = DBXPaperPaperDocExportResult(swift: swift.0)
                destination = swift.1
            }
            completionHandler(objc, destination, routeError, callError)
        }
        return self
    }

    @objc
    public func progress(_ progressHandler: @escaping ((Progress) -> Void)) -> Self {
        swift.progress(progressHandler)
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
public class DBXPaperDocsFolderUsersListRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<Paper.ListUsersOnFolderResponseSerializer, Paper.DocLookupErrorSerializer>

    init(swift: RpcRequest<Paper.ListUsersOnFolderResponseSerializer, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperListUsersOnFolderResponse?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperListUsersOnFolderResponse?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperListUsersOnFolderResponse?
            if let swift = result {
                objc = DBXPaperListUsersOnFolderResponse(swift: swift)
            }
            completionHandler(objc, routeError, callError)
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
public class DBXPaperDocsFolderUsersListContinueRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<Paper.ListUsersOnFolderResponseSerializer, Paper.ListUsersCursorErrorSerializer>

    init(swift: RpcRequest<Paper.ListUsersOnFolderResponseSerializer, Paper.ListUsersCursorErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperListUsersOnFolderResponse?, DBXPaperListUsersCursorError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperListUsersOnFolderResponse?, DBXPaperListUsersCursorError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperListUsersCursorError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperListUsersCursorError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperListUsersOnFolderResponse?
            if let swift = result {
                objc = DBXPaperListUsersOnFolderResponse(swift: swift)
            }
            completionHandler(objc, routeError, callError)
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
public class DBXPaperDocsGetFolderInfoRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<Paper.FoldersContainingPaperDocSerializer, Paper.DocLookupErrorSerializer>

    init(swift: RpcRequest<Paper.FoldersContainingPaperDocSerializer, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperFoldersContainingPaperDoc?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperFoldersContainingPaperDoc?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperFoldersContainingPaperDoc?
            if let swift = result {
                objc = DBXPaperFoldersContainingPaperDoc(swift: swift)
            }
            completionHandler(objc, routeError, callError)
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
public class DBXPaperDocsListRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<Paper.ListPaperDocsResponseSerializer, VoidSerializer>

    init(swift: RpcRequest<Paper.ListPaperDocsResponseSerializer, VoidSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperListPaperDocsResponse?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperListPaperDocsResponse?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var objc: DBXPaperListPaperDocsResponse?
            if let swift = result {
                objc = DBXPaperListPaperDocsResponse(swift: swift)
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

@objc
public class DBXPaperDocsListContinueRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<Paper.ListPaperDocsResponseSerializer, Paper.ListDocsCursorErrorSerializer>

    init(swift: RpcRequest<Paper.ListPaperDocsResponseSerializer, Paper.ListDocsCursorErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperListPaperDocsResponse?, DBXPaperListDocsCursorError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperListPaperDocsResponse?, DBXPaperListDocsCursorError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperListDocsCursorError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperListDocsCursorError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperListPaperDocsResponse?
            if let swift = result {
                objc = DBXPaperListPaperDocsResponse(swift: swift)
            }
            completionHandler(objc, routeError, callError)
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
public class DBXPaperDocsPermanentlyDeleteRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<VoidSerializer, Paper.DocLookupErrorSerializer>

    init(swift: RpcRequest<VoidSerializer, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { _, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
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

@objc
public class DBXPaperDocsSharingPolicyGetRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<Paper.SharingPolicySerializer, Paper.DocLookupErrorSerializer>

    init(swift: RpcRequest<Paper.SharingPolicySerializer, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperSharingPolicy?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperSharingPolicy?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperSharingPolicy?
            if let swift = result {
                objc = DBXPaperSharingPolicy(swift: swift)
            }
            completionHandler(objc, routeError, callError)
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
public class DBXPaperDocsSharingPolicySetRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<VoidSerializer, Paper.DocLookupErrorSerializer>

    init(swift: RpcRequest<VoidSerializer, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { _, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
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

@objc
public class DBXPaperDocsUpdateUploadRequest: NSObject, DBXRequest {
    var swift: UploadRequest<Paper.PaperDocCreateUpdateResultSerializer, Paper.PaperDocUpdateErrorSerializer>

    init(swift: UploadRequest<Paper.PaperDocCreateUpdateResultSerializer, Paper.PaperDocUpdateErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperPaperDocCreateUpdateResult?, DBXPaperPaperDocUpdateError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperPaperDocCreateUpdateResult?, DBXPaperPaperDocUpdateError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperPaperDocUpdateError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperPaperDocUpdateError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperPaperDocCreateUpdateResult?
            if let swift = result {
                objc = DBXPaperPaperDocCreateUpdateResult(swift: swift)
            }
            completionHandler(objc, routeError, callError)
        }
        return self
    }

    @objc
    public func progress(_ progressHandler: @escaping ((Progress) -> Void)) -> Self {
        swift.progress(progressHandler)
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
public class DBXPaperDocsUsersAddRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<ArraySerializer<Paper.AddPaperDocUserMemberResultSerializer>, Paper.DocLookupErrorSerializer>

    init(swift: RpcRequest<ArraySerializer<Paper.AddPaperDocUserMemberResultSerializer>, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping ([DBXPaperAddPaperDocUserMemberResult]?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping ([DBXPaperAddPaperDocUserMemberResult]?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: [DBXPaperAddPaperDocUserMemberResult]?
            if let swift = result {
                objc = swift.map { DBXPaperAddPaperDocUserMemberResult(swift: $0) }
            }
            completionHandler(objc, routeError, callError)
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
public class DBXPaperDocsUsersListRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<Paper.ListUsersOnPaperDocResponseSerializer, Paper.DocLookupErrorSerializer>

    init(swift: RpcRequest<Paper.ListUsersOnPaperDocResponseSerializer, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperListUsersOnPaperDocResponse?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperListUsersOnPaperDocResponse?, DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperListUsersOnPaperDocResponse?
            if let swift = result {
                objc = DBXPaperListUsersOnPaperDocResponse(swift: swift)
            }
            completionHandler(objc, routeError, callError)
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
public class DBXPaperDocsUsersListContinueRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<Paper.ListUsersOnPaperDocResponseSerializer, Paper.ListUsersCursorErrorSerializer>

    init(swift: RpcRequest<Paper.ListUsersOnPaperDocResponseSerializer, Paper.ListUsersCursorErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperListUsersOnPaperDocResponse?, DBXPaperListUsersCursorError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperListUsersOnPaperDocResponse?, DBXPaperListUsersCursorError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperListUsersCursorError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperListUsersCursorError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperListUsersOnPaperDocResponse?
            if let swift = result {
                objc = DBXPaperListUsersOnPaperDocResponse(swift: swift)
            }
            completionHandler(objc, routeError, callError)
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
public class DBXPaperDocsUsersRemoveRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<VoidSerializer, Paper.DocLookupErrorSerializer>

    init(swift: RpcRequest<VoidSerializer, Paper.DocLookupErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperDocLookupError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { _, error in
            var routeError: DBXPaperDocLookupError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperDocLookupError.factory(swift: box.unboxed)
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

@objc
public class DBXPaperFoldersCreateRpcRequest: NSObject, DBXRequest {
    var swift: RpcRequest<Paper.PaperFolderCreateResultSerializer, Paper.PaperFolderCreateErrorSerializer>

    init(swift: RpcRequest<Paper.PaperFolderCreateResultSerializer, Paper.PaperFolderCreateErrorSerializer>) {
        self.swift = swift
    }

    @objc
    @discardableResult public func response(
        completionHandler: @escaping (DBXPaperPaperFolderCreateResult?, DBXPaperPaperFolderCreateError?, DBXCallError?) -> Void
    ) -> Self {
        response(queue: nil, completionHandler: completionHandler)
    }

    @objc
    @discardableResult public func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (DBXPaperPaperFolderCreateResult?, DBXPaperPaperFolderCreateError?, DBXCallError?) -> Void
    ) -> Self {
        swift.response(queue: queue) { result, error in
            var routeError: DBXPaperPaperFolderCreateError?
            var callError: DBXCallError?
            switch error {
            case .routeError(let box, _, _, _):
                routeError = DBXPaperPaperFolderCreateError.factory(swift: box.unboxed)
                callError = nil
            default:
                routeError = nil
                callError = error?.objc
            }

            var objc: DBXPaperPaperFolderCreateResult?
            if let swift = result {
                objc = DBXPaperPaperFolderCreateResult(swift: swift)
            }
            completionHandler(objc, routeError, callError)
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
