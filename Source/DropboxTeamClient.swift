import Foundation
import Alamofire

/// The client for the Business API. Call routes using the namespaces inside this object (inherited from parent).

public class DropboxTeamClient: DropboxTeamBase {
    private var dropboxTransportClient: DropboxTransportClient
    private var accessToken: DropboxAccessToken
    
    public convenience init(accessToken: DropboxAccessToken) {
        let dropboxTransportClient = DropboxTransportClient(accessToken: accessToken)
        self.init(dropboxTransportClient: dropboxTransportClient)
        self.accessToken = accessToken
    }
    
    public init(dropboxTransportClient: DropboxTransportClient) {
        self.dropboxTransportClient = dropboxTransportClient
        self.accessToken = dropboxTransportClient.accessToken
        super.init(client: dropboxTransportClient)
    }

    public func asMember(memberId: String) -> DropboxClient {
        return DropboxClient(accessToken: self.accessToken, selectUser: memberId)
    }
}
