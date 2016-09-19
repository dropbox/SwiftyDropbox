///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation
import Alamofire

/// The client for the User API. Call routes using the namespaces inside this object (inherited from parent).

open class DropboxClient: DropboxBase {
    fileprivate var transportClient: DropboxTransportClient

    public convenience init(accessToken: String, selectUser: String? = nil) {
        let transportClient = DropboxTransportClient(accessToken: accessToken, selectUser: selectUser)
        self.init(transportClient: transportClient)
    }

    public init(transportClient: DropboxTransportClient) {
        self.transportClient = transportClient
        super.init(client: transportClient)
    }
}
