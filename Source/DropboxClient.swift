import Foundation
import Alamofire

/// The client for the User API. Call routes using the namespaces inside this object (inherited from parent).

public class DropboxClient: DropboxBase {
    private var dropboxTransportClient: DropboxTransportClient
    
    public convenience init(accessToken: DropboxAccessToken, selectUser: String? = nil) {
        let dropboxTransportClient = DropboxTransportClient(accessToken: accessToken, selectUser: selectUser)
        self.init(dropboxTransportClient: dropboxTransportClient)
    }

    public init(dropboxTransportClient: DropboxTransportClient) {
        self.dropboxTransportClient = dropboxTransportClient
        super.init(client: dropboxTransportClient)
    }
}
