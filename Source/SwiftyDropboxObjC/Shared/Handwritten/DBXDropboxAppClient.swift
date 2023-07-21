///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

/// The client for the App API. Call routes using the namespaces inside this object (inherited from parent).
@objc
public class DBXDropboxAppClient: DBXDropboxAppBase {
    let subSwift: DropboxAppClient

    /// Initialize a client from swift using an existing Swift client.
    ///
    /// - Parameter swift: The underlying DropboxAppClient to make API calls.
    public init(swift: DropboxAppClient) {
        self.subSwift = swift
        super.init(swiftClient: swift.client)
    }

    /// Designated Initializer.
    ///
    /// - Parameter transportClient: The underlying DropboxTransportClient to make API calls.
    @objc
    public convenience init(transportClient: DBXDropboxTransportClient) {
        self.init(swift: DropboxAppClient(transportClient: transportClient.swift))
    }
}
