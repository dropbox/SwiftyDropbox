///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation

/// Routes for the openid namespace
/// For Objective-C compatible routes see DBOpenidRoutes
public class OpenidRoutes {
    public let client: DropboxTransportClient
    init(client: DropboxTransportClient) {
        self.client = client
    }

    /// This route is used for refreshing the info that is found in the id_token during the OIDC flow. This route
    /// doesn't require any arguments and will use the scopes approved for the given access token.
    ///
    /// - scope: openid
    ///
    ///
    /// - returns: Through the response callback, the caller will receive a `Openid.UserInfoResult` object on success or
    /// a `Openid.UserInfoError` object on failure.
    @discardableResult public func userinfo() -> RpcRequest<Openid.UserInfoResultSerializer, Openid.UserInfoErrorSerializer> {
        let route = Openid.userinfo
        let serverArgs = Openid.UserInfoArgs()
        return client.request(route, serverArgs: serverArgs)
    }
}
