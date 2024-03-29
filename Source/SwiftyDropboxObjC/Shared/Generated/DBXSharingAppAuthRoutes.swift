///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation
import SwiftyDropbox

/// Objective-C compatible routes for the sharing namespace
/// For Swift routes see SharingAppAuthRoutes
@objc
public class DBXSharingAppAuthRoutes: NSObject {
    private let swift: SharingAppAuthRoutes
    init(swift: SharingAppAuthRoutes) {
        self.swift = swift
        self.client = swift.client.objc
    }

    public let client: DBXDropboxTransportClient

    /// Get the shared link's metadata.
    ///
    /// - scope: sharing.read
    ///
    /// - parameter url: URL of the shared link.
    /// - parameter path: If the shared link is to a folder, this parameter can be used to retrieve the metadata for a
    /// specific file or sub-folder in this folder. A relative path should be used.
    /// - parameter linkPassword: If the shared link has a password, this parameter can be used.
    ///
    /// - returns: Through the response callback, the caller will receive a `Sharing.SharedLinkMetadata` object on
    /// success or a `Sharing.SharedLinkError` object on failure.
    @objc
    @discardableResult public func getSharedLinkMetadata(url: String, path: String?, linkPassword: String?) -> DBXSharingGetSharedLinkMetadataRpcRequest {
        let swift = swift.getSharedLinkMetadata(url: url, path: path, linkPassword: linkPassword)
        return DBXSharingGetSharedLinkMetadataRpcRequest(swift: swift)
    }

    /// Get the shared link's metadata.
    ///
    /// - scope: sharing.read
    ///
    /// - returns: Through the response callback, the caller will receive a `Sharing.SharedLinkMetadata` object on
    /// success or a `Sharing.SharedLinkError` object on failure.
    @objc
    @discardableResult public func getSharedLinkMetadata(url: String) -> DBXSharingGetSharedLinkMetadataRpcRequest {
        let swift = swift.getSharedLinkMetadata(url: url)
        return DBXSharingGetSharedLinkMetadataRpcRequest(swift: swift)
    }
}
