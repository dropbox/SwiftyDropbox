///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

/// The client for the App API. Call routes using the namespaces inside this object (inherited from parent).

public class DropboxAppClient: DropboxAppBase {
    private var transportClient: DropboxTransportClient

    /// Designated Initializer.
    ///
    /// - Parameter transportClient: The underlying DropboxTransportClient to make API calls.
    public init(transportClient: DropboxTransportClient) {
        self.transportClient = transportClient
        super.init(client: transportClient)
    }

    /// Initializer used by DropboxTransportClientOwning in tests.
    ///
    /// - Parameter client: The underlying DropboxTransportClient to make API calls.
    required convenience init(client: DropboxTransportClient) {
        self.init(transportClient: client)
    }
}
