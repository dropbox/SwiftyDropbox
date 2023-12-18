///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

extension DropboxTransportClient {
    var objc: DBXDropboxTransportClient {
        DBXDropboxTransportClient(swift: self)
    }
}

@objc
public class DBXDropboxTransportClient: NSObject {
    var swift: DropboxTransportClient

    @objc
    public var selectUser: String? {
        get { swift.selectUser }
        set { swift.selectUser = newValue }
    }

    @objc
    public var pathRoot: DBXCommonPathRoot? {
        get {
            guard let swift = swift.pathRoot else { return nil }
            return DBXCommonPathRoot(swift: swift)
        }
        set { swift.pathRoot = newValue?.swift }
    }

    @objc
    public var didFinishBackgroundEvents: (() -> Void)? {
        get { swift.didFinishBackgroundEvents }
        set { swift.didFinishBackgroundEvents = newValue }
    }

    @objc
    public convenience init(
        accessToken: String,
        selectUser: String? = nil,
        sessionConfiguration: DBXNetworkSessionConfiguration? = nil,
        pathRoot: DBXCommonPathRoot? = nil
    ) {
        self.init(
            accessToken: accessToken,
            selectUser: selectUser,
            sessionConfiguration: sessionConfiguration ?? .default,
            pathRoot: pathRoot
        )
    }

    @objc
    public convenience init(
        accessToken: String,
        baseHosts: BaseHosts = .default,
        userAgent: String? = nil,
        selectUser: String? = nil,
        sessionConfiguration: DBXNetworkSessionConfiguration = DBXNetworkSessionConfiguration.default,
        longpollSessionConfiguration: DBXNetworkSessionConfiguration = DBXNetworkSessionConfiguration.defaultLongpoll,
        filesAccess: FilesAccess = FilesAccessImpl(),
        authChallengeHandler: DBXAuthChallengeHandler? = nil,
        pathRoot: DBXCommonPathRoot? = nil
    ) {
        self.init(
            accessTokenProvider: DBXLongLivedAccessTokenProvider(accessToken: accessToken),
            baseHosts: baseHosts,
            userAgent: userAgent,
            selectUser: selectUser,
            sessionConfiguration: sessionConfiguration,
            longpollSessionConfiguration: longpollSessionConfiguration,
            filesAccess: filesAccess,
            authChallengeHandler: authChallengeHandler,
            pathRoot: pathRoot
        )
    }

    @objc
    public convenience init(
        accessTokenProvider: DBXAccessTokenProvider,
        selectUser: String? = nil,
        sessionConfiguration: DBXNetworkSessionConfiguration? = nil,
        pathRoot: DBXCommonPathRoot? = nil
    ) {
        self.init(
            accessTokenProvider: accessTokenProvider,
            userAgent: nil,
            selectUser: selectUser,
            sessionConfiguration: sessionConfiguration ?? .default,
            pathRoot: pathRoot
        )
    }

    convenience init(
        accessTokenProvider: DBXAccessTokenProvider,
        baseHosts: BaseHosts = .default,
        userAgent: String?,
        selectUser: String?,
        sessionConfiguration: DBXNetworkSessionConfiguration = DBXNetworkSessionConfiguration.default,
        longpollSessionConfiguration: DBXNetworkSessionConfiguration = DBXNetworkSessionConfiguration.defaultLongpoll,
        filesAccess: FilesAccess = FilesAccessImpl(),
        authChallengeHandler: DBXAuthChallengeHandler? = nil,
        pathRoot: DBXCommonPathRoot? = nil
    ) {
        let swift = DropboxTransportClientImpl(
            accessTokenProvider: accessTokenProvider,
            baseHosts: baseHosts,
            userAgent: userAgent,
            selectUser: selectUser,
            sessionConfiguration: sessionConfiguration.swift,
            longpollSessionConfiguration: longpollSessionConfiguration.swift,
            filesAccess: filesAccess,
            authChallengeHandler: authChallengeHandler?.swift,
            pathRoot: pathRoot?.swift
        )
        self.init(swift: swift)
    }

    fileprivate init(swift: DropboxTransportClient) {
        self.swift = swift
    }
}

/// Only called by other ObjC wrappers and/or other Swift code
extension DBXDropboxTransportClient {
    public func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>, serverArgs: ASerial.ValueType? = nil
    ) -> RpcRequest<RSerial, ESerial> {
        swift.request(route, serverArgs: serverArgs)
    }

    public func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>, serverArgs: ASerial.ValueType, input: UploadBody
    ) -> UploadRequest<RSerial, ESerial> {
        swift.request(route, serverArgs: serverArgs, input: input)
    }

    public func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType,
        overwrite: Bool,
        destination: URL
    ) -> DownloadRequestFile<RSerial, ESerial> {
        swift.request(route, serverArgs: serverArgs, overwrite: overwrite, destination: destination)
    }

    public func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType
    ) -> DownloadRequestMemory<RSerial, ESerial> {
        swift.request(route, serverArgs: serverArgs)
    }
}
