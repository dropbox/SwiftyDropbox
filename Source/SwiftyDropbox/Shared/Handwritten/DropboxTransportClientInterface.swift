///
/// Copyright (c) 2023 Dropbox, Inc. All rights reserved.
///

import Foundation

public protocol DropboxTransportClient {
    var selectUser: String? { get set }
    var pathRoot: Common.PathRoot? { get set }
    var didFinishBackgroundEvents: (() -> Void)? { get set }
    var accessTokenProvider: AccessTokenProvider? { get set }
    var isBackgroundClient: Bool { get }

    var identifier: String? { get }

    func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>
    ) -> RpcRequest<RSerial, ESerial>

    func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType?
    ) -> RpcRequest<RSerial, ESerial>

    func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType,
        input: UploadBody
    ) -> UploadRequest<RSerial, ESerial>

    func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType,
        overwrite: Bool,
        destination: URL
    ) -> DownloadRequestFile<RSerial, ESerial>

    func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType
    ) -> DownloadRequestMemory<RSerial, ESerial>

    func shutdown()
}

protocol DropboxTransportClientInternal: DropboxTransportClient {
    var manager: NetworkSessionManager { get }
    var longpollManager: NetworkSessionManager { get }

    func reconnectRequest<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        apiRequest: ApiRequest
    ) -> UploadRequest<RSerial, ESerial>

    func reconnectRequest<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        apiRequest: ApiRequest,
        overwrite: Bool,
        destination: URL
    ) -> DownloadRequestFile<RSerial, ESerial>
}

typealias SessionCreation = (NetworkSessionConfiguration, CombinedURLSessionDelegate, OperationQueue) -> NetworkSession
let DefaultSessionCreation: SessionCreation = { configuration, delegate, queue in
    URLSession(configuration: configuration.urlSessionConfiguration, delegate: delegate, delegateQueue: queue)
}

public typealias HeadersForRouteRequest = (RouteHost) -> [String: String]

public enum AuthStrategy {
    case accessToken(AccessTokenProvider)
    case appKeyAndSecret(String, String)

    var accessTokenHeaderValue: String? {
        if case .accessToken(let provider) = self {
            return "Bearer \(provider.accessToken)"
        }
        return nil
    }

    var appKeyAndSecretHeaderValue: String? {
        if case .appKeyAndSecret(let appKey, let appSecret) = self {
            let authString = "\(appKey):\(appSecret)"
            let authData = authString.data(using: .utf8) ?? .init()
            return "Basic \(authData.base64EncodedString())"
        }
        return nil
    }

    var accessTokenProvider: AccessTokenProvider? {
        if case .accessToken(let provider) = self {
            return provider
        }
        return nil
    }
}
