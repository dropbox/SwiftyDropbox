///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation

/// Routes for the sharingAppAuth namespace
/// For Objective-C compatible routes see DBSharingRoutes
public class SharingAppAuthRoutes: DropboxTransportClientOwning {
    public let client: DropboxTransportClient
    required init(client: DropboxTransportClient) {
        self.client = client
    }

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
    @discardableResult public func getSharedLinkMetadata(
        url: String,
        path: String? = nil,
        linkPassword: String? = nil
    ) -> RpcRequest<Sharing.SharedLinkMetadataSerializer, Sharing.SharedLinkErrorSerializer> {
        let route = Sharing.getSharedLinkMetadata
        let serverArgs = Sharing.GetSharedLinkMetadataArg(url: url, path: path, linkPassword: linkPassword)
        return client.request(route, serverArgs: serverArgs)
    }
}
