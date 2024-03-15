///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation

/// Constants used to make API requests. e.g. server addresses and default user agent to be used.
enum ApiClientConstants {
    static let apiHost = "https://api.dropbox.com"
    static let contentHost = "https://api-content.dropbox.com"
    static let notifyHost = "https://notify.dropboxapi.com"
    static let defaultUserAgent = "OfficialDropboxSwiftSDKv2/\(Constants.versionSDK)"
}

public class DropboxTransportClientImpl: DropboxTransportClientInternal {
    public var identifier: String? {
        manager.identifier
    }

    public let filesAccess: FilesAccess
    public var selectUser: String?
    public var pathRoot: Common.PathRoot?
    let manager: NetworkSessionManager
    let longpollManager: NetworkSessionManager
    var baseHosts: BaseHosts
    var userAgent: String
    var authStrategy: AuthStrategy
    var headersForRouteHost: HeadersForRouteRequest?

    public var accessTokenProvider: AccessTokenProvider? {
        get {
            authStrategy.accessTokenProvider
        }
        set {
            if let newValue = newValue {
                authStrategy = .accessToken(newValue)
            }
        }
    }

    public var isBackgroundClient: Bool {
        manager.isBackgroundManager
    }

    public var didFinishBackgroundEvents: (() -> Void)?

    public convenience init(
        appKey: String,
        appSecret: String,
        baseHosts: BaseHosts = .default,
        firstPartyUserAgent: String?,
        authChallengeHandler: @escaping AuthChallenge.Handler
    ) {
        self.init(
            authStrategy: .appKeyAndSecret(appKey, appSecret),
            baseHosts: baseHosts,
            userAgent: nil,
            firstPartyUserAgent: firstPartyUserAgent,
            selectUser: nil,
            sessionCreation: DefaultSessionCreation,
            authChallengeHandler: authChallengeHandler
        )
    }

    public convenience init(
        accessToken: String,
        selectUser: String? = nil,
        sessionConfiguration: NetworkSessionConfiguration? = nil,
        pathRoot: Common.PathRoot? = nil
    ) {
        self.init(
            accessToken: accessToken,
            userAgent: nil,
            selectUser: selectUser,
            sessionConfiguration: sessionConfiguration ?? .default,
            pathRoot: pathRoot
        )
    }

    public convenience init(
        accessToken: String,
        baseHosts: BaseHosts = .default,
        userAgent: String? = nil,
        firstPartyUserAgent: String? = nil,
        selectUser: String? = nil,
        sessionConfiguration: NetworkSessionConfiguration = .default,
        longpollSessionConfiguration: NetworkSessionConfiguration = .defaultLongpoll,
        filesAccess: FilesAccess = FilesAccessImpl(),
        authChallengeHandler: AuthChallenge.Handler? = nil,
        pathRoot: Common.PathRoot? = nil,
        headersForRouteHost: HeadersForRouteRequest? = nil
    ) {
        self.init(
            accessTokenProvider: LongLivedAccessTokenProvider(accessToken: accessToken),
            baseHosts: baseHosts,
            userAgent: userAgent,
            firstPartyUserAgent: firstPartyUserAgent,
            selectUser: selectUser,
            sessionConfiguration: sessionConfiguration,
            longpollSessionConfiguration: longpollSessionConfiguration,
            filesAccess: filesAccess,
            authChallengeHandler: authChallengeHandler,
            pathRoot: pathRoot,
            headersForRouteHost: headersForRouteHost
        )
    }

    public convenience init(
        accessTokenProvider: AccessTokenProvider,
        selectUser: String? = nil,
        sessionConfiguration: NetworkSessionConfiguration? = nil,
        pathRoot: Common.PathRoot? = nil
    ) {
        self.init(
            accessTokenProvider: accessTokenProvider, userAgent: nil,
            selectUser: selectUser, sessionConfiguration: sessionConfiguration ?? .default, pathRoot: pathRoot
        )
    }

    public convenience init(
        accessTokenProvider: AccessTokenProvider,
        baseHosts: BaseHosts = .default,
        userAgent: String?,
        firstPartyUserAgent: String? = nil,
        selectUser: String?,
        sessionConfiguration: NetworkSessionConfiguration = .default,
        longpollSessionConfiguration: NetworkSessionConfiguration = .defaultLongpoll,
        filesAccess: FilesAccess = FilesAccessImpl(),
        authChallengeHandler: AuthChallenge.Handler? = nil,
        pathRoot: Common.PathRoot? = nil,
        headersForRouteHost: HeadersForRouteRequest? = nil
    ) {
        self.init(
            authStrategy: .accessToken(accessTokenProvider),
            baseHosts: baseHosts,
            userAgent: userAgent,
            firstPartyUserAgent: firstPartyUserAgent,
            selectUser: selectUser,
            sessionConfiguration: sessionConfiguration,
            sessionCreation: DefaultSessionCreation,
            longpollSessionConfiguration: longpollSessionConfiguration,
            longpollSessionCreation: DefaultSessionCreation,
            filesAccess: filesAccess,
            authChallengeHandler: authChallengeHandler,
            pathRoot: pathRoot,
            headersForRouteHost: headersForRouteHost
        )
    }

    convenience init(
        accessToken: String,
        selectUser: String? = nil,
        pathRoot: Common.PathRoot? = nil,
        sessionCreation: SessionCreation = DefaultSessionCreation,
        headersForRouteHost: HeadersForRouteRequest? = nil
    ) {
        self.init(
            authStrategy: .accessToken(
                LongLivedAccessTokenProvider(accessToken: accessToken)
            ),
            userAgent: nil,
            firstPartyUserAgent: nil,
            selectUser: selectUser,
            sessionCreation: sessionCreation,
            authChallengeHandler: nil,
            pathRoot: pathRoot,
            headersForRouteHost: headersForRouteHost
        )
    }

    init(
        authStrategy: AuthStrategy,
        baseHosts: BaseHosts = .default,
        userAgent: String?,
        firstPartyUserAgent: String?,
        selectUser: String?,
        sessionConfiguration: NetworkSessionConfiguration = .default,
        sessionCreation: SessionCreation = DefaultSessionCreation,
        longpollSessionConfiguration: NetworkSessionConfiguration = .defaultLongpoll,
        longpollSessionCreation: SessionCreation = DefaultSessionCreation,
        filesAccess: FilesAccess = FilesAccessImpl(),
        authChallengeHandler: AuthChallenge.Handler?,
        pathRoot: Common.PathRoot? = nil,
        headersForRouteHost: HeadersForRouteRequest? = nil
    ) {
        self.filesAccess = filesAccess

        let apiRequestReconnectionCreation: ((NetworkTask) -> ApiRequest)? = { task in
            RequestWithTokenRefresh(backgroundRequest: task, filesAccess: filesAccess)
        }

        self.manager = NetworkSessionManager(
            sessionCreation: { delegate, queue in
                sessionCreation(sessionConfiguration, delegate, queue)
            },
            apiRequestReconnectionCreation: apiRequestReconnectionCreation,
            authChallengeHandler: authChallengeHandler
        )

        self.longpollManager = NetworkSessionManager(
            sessionCreation: { delegate, queue in
                sessionCreation(longpollSessionConfiguration, delegate, queue)
            },
            apiRequestReconnectionCreation: nil,
            authChallengeHandler: authChallengeHandler
        )

        self.authStrategy = authStrategy
        self.selectUser = selectUser
        self.pathRoot = pathRoot
        self.baseHosts = baseHosts

        let defaultUserAgent = ApiClientConstants.defaultUserAgent

        if let firstPartyUserAgent = firstPartyUserAgent {
            self.userAgent = firstPartyUserAgent
        } else if let userAgent = userAgent {
            self.userAgent = "\(userAgent)/\(defaultUserAgent)"
        } else {
            self.userAgent = defaultUserAgent
        }

        self.headersForRouteHost = headersForRouteHost

        // below this self is initialized

        let apiRequestCreation: ApiRequestCreation = { [weak self] taskCreation, onTaskCreation in
            guard let self = self else {
                return NoopApiRequest()
            }

            return RequestWithTokenRefresh(
                requestCreation: taskCreation,
                onTaskCreation: onTaskCreation,
                authStrategy: self.authStrategy, // reference the authStrategy stored on self so updates to it are propagated.
                filesAccess: filesAccess
            )
        }

        manager.apiRequestCreation = apiRequestCreation
        longpollManager.apiRequestCreation = apiRequestCreation
    }

    public func shutdown() {
        manager.shutdown()
        longpollManager.shutdown()
    }

    public func request<ASerial, RSerial, ESerial>(_ route: Route<ASerial, RSerial, ESerial>) -> RpcRequest<RSerial, ESerial> where ASerial: JSONSerializer,
        RSerial: JSONSerializer, ESerial: JSONSerializer {
        request(route, serverArgs: nil)
    }

    public func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>, serverArgs: ASerial.ValueType?
    ) -> RpcRequest<RSerial, ESerial> {
        let managerToUse = type(of: route) == type(of: Files.listFolderLongpoll)
            ? longpollManager
            : manager

        let urlRequest = { self.createRpcRequest(route: route, serverArgs: serverArgs) }
        let apiRequest = managerToUse.apiRequestData(request: urlRequest)

        return RpcRequest(
            request: apiRequest,
            responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer
        )
    }

    public func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>, serverArgs: ASerial.ValueType, input: UploadBody
    ) -> UploadRequest<RSerial, ESerial> {
        var apiRequest = manager.apiRequestUpload(
            request: { self.createUploadRequest(route: route, serverArgs: serverArgs, input: input) },
            input: input
        )

        if manager.isBackgroundManager {
            let persistedInfo = ReconnectionHelpers.PersistedRequestInfo.upload(
                .init(
                    originalSDKVersion: DropboxClientsManager.sdkVersion,
                    routeName: route.name,
                    routeNamespace: route.namespace,
                    clientProvidedInfo: nil
                )
            )

            apiRequest.taskDescription = try? persistedInfo.asJsonString()
        }

        return UploadRequest(
            request: apiRequest,
            responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer
        )
    }

    func reconnectRequest<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        apiRequest: ApiRequest
    ) -> UploadRequest<RSerial, ESerial> {
        UploadRequest(
            request: apiRequest,
            responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer
        )
    }

    public func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType,
        overwrite: Bool,
        destination: URL
    ) -> DownloadRequestFile<RSerial, ESerial> {
        var apiRequest = manager.apiRequestDownloadFile(
            request: { self.createDownloadRequest(route: route, serverArgs: serverArgs) }
        )

        if manager.isBackgroundManager {
            let persistedInfo = ReconnectionHelpers.PersistedRequestInfo.downloadFile(
                .init(
                    originalSDKVersion: DropboxClientsManager.sdkVersion,
                    routeName: route.name,
                    routeNamespace: route.namespace,
                    clientProvidedInfo: nil,
                    destination: destination,
                    overwrite: overwrite
                )
            )

            apiRequest.taskDescription = try? persistedInfo.asJsonString()
        }

        let downloadRequest = DownloadRequestFile(
            request: apiRequest,
            responseSerializer: route.responseSerializer,
            errorSerializer: route.errorSerializer,
            moveToDestination: { [weak self] temporaryLocation in
                try (self.orThrow()).filesAccess.moveFile(
                    from: temporaryLocation,
                    to: destination,
                    overwrite: overwrite
                )
            }, errorDataFromLocation: { [weak self] url in
                try self?.filesAccess.errorData(from: url)
            }
        )

        return downloadRequest
    }

    func reconnectRequest<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        apiRequest: ApiRequest,
        overwrite: Bool,
        destination: URL
    ) -> DownloadRequestFile<RSerial, ESerial> {
        let downloadRequest = DownloadRequestFile(
            request: apiRequest,
            responseSerializer: route.responseSerializer,
            errorSerializer: route.errorSerializer,
            moveToDestination: { [weak self] temporaryLocation in
                try (self.orThrow()).filesAccess.moveFile(
                    from: temporaryLocation,
                    to: destination,
                    overwrite: overwrite
                )
            }, errorDataFromLocation: { [weak self] url in
                try self?.filesAccess.errorData(from: url)
            }
        )
        return downloadRequest
    }

    public func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType
    ) -> DownloadRequestMemory<RSerial, ESerial> {
        let urlRequest = { self.createDownloadRequest(route: route, serverArgs: serverArgs) }
        let apiRequest = manager.apiRequestData(request: urlRequest)

        return DownloadRequestMemory(
            request: apiRequest, responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer
        )
    }

    private func getHeaders(_ attributes: RouteAttributes, jsonRequest: Data?) -> [String: String] {
        var headers = ["User-Agent": userAgent]

        let additionalHeaders = headersForRouteHost?(attributes.host) ?? [:]
        for (key, value) in additionalHeaders {
            headers[key] = value
        }

        let noauth = (attributes.auth.contains(.noauth))

        if !noauth {
            if let selectUser = selectUser {
                headers["Dropbox-Api-Select-User"] = selectUser
            }

            if let pathRoot = pathRoot,
               let obj = try? Common.PathRootSerializer().serialize(pathRoot),
               let data = try? SerializeUtil.dumpJSON(obj) {
                headers["Dropbox-Api-Path-Root"] = Utilities.utf8Decode(data)
            }

            if attributes.auth.contains(.user)
                || attributes.auth.contains(.team),
                let headerValue = authStrategy.accessTokenHeaderValue {
                headers["Authorization"] = headerValue
            } else if attributes.auth.contains(.app),
                      let headerValue = authStrategy.appKeyAndSecretHeaderValue {
                headers["Authorization"] = headerValue
            }
        }

        switch attributes.style {
        case .rpc:
            headers["Content-Type"] = "application/json"
        case .upload:
            headers["Content-Type"] = "application/octet-stream"
            if let jsonRequest = jsonRequest {
                let value = Utilities.asciiEscape(Utilities.utf8Decode(jsonRequest))
                headers["Dropbox-Api-Arg"] = value
            }
        case .download:
            if let jsonRequest = jsonRequest {
                let value = Utilities.asciiEscape(Utilities.utf8Decode(jsonRequest))
                headers["Dropbox-Api-Arg"] = value
            }
        }

        return headers
    }

    private func createRpcRequest<ASerial, RSerial, ESerial>(
        route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType? = nil
    ) -> URLRequest {
        let jsonRequestObj: JSON = serverArgs.flatMap { try? route.argSerializer.serialize($0) } ?? .null
        let rawJSONData = try? SerializeUtil.dumpJSON(jsonRequestObj)

        return urlRequest(
            for: route,
            serverArgs: serverArgs,
            bodyData: rawJSONData,
            stream: nil
        )
    }

    private func createUploadRequest<ASerial, RSerial, ESerial>(
        route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType,
        input: UploadBody
    ) -> URLRequest {
        switch input {
        case .data, .file:
            return urlRequest(for: route, serverArgs: serverArgs, bodyData: nil, stream: nil)
        case .stream(let stream):
            return urlRequest(for: route, serverArgs: serverArgs, bodyData: nil, stream: stream)
        }
    }

    private func createDownloadRequest<ASerial, RSerial, ESerial>(
        route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType
    ) -> URLRequest {
        urlRequest(for: route, serverArgs: serverArgs, bodyData: nil, stream: nil)
    }

    private func urlRequest<ASerial, RSerial, ESerial>(
        for route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType?,
        bodyData: Data?,
        stream: InputStream?
    ) -> URLRequest {
        let attributes = route.attributes

        let jsonRequestObj: JSON = serverArgs.flatMap { try? route.argSerializer.serialize($0) } ?? .null
        let rawJsonRequest = try? SerializeUtil.dumpJSON(jsonRequestObj)

        let headers = getHeaders(attributes, jsonRequest: rawJsonRequest)

        var urlRequest = URLRequest(url: Self.url(for: route, baseHosts: baseHosts))

        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = headers

        if attributes.style == .upload || attributes.style == .download {
            urlRequest.networkServiceType = .responsiveData
        }

        if let bodyData = bodyData {
            urlRequest.httpBody = bodyData
        }
        if let stream = stream {
            urlRequest.httpBodyStream = stream
        }
        return urlRequest
    }

    static func url<ASerial, RSerial, ESerial>(
        for route: Route<ASerial, RSerial, ESerial>,
        baseHosts: BaseHosts = .default
    ) -> URL {
        let urlString = "\(baseHosts.url(for: route.attributes.host))/\(route.namespace)/\(route.name)"
        return URL(string: urlString)!
    }

    var __testing_only_backgroundUrlSession: URLSession? {
        if manager.isBackgroundManager {
            return manager.__testing_only_urlSession
        }
        return nil
    }
}

@objc(DBXBaseHosts)
public class BaseHosts: NSObject {
    @objc
    let apiHost: String
    @objc
    let contentHost: String
    @objc
    let notifyHost: String

    @objc
    public required init(
        apiHost: String,
        contentHost: String,
        notifyHost: String
    ) {
        self.apiHost = apiHost
        self.contentHost = contentHost
        self.notifyHost = notifyHost
    }

    public static var `default`: Self {
        .init(
            apiHost: ApiClientConstants.apiHost,
            contentHost: ApiClientConstants.contentHost,
            notifyHost: ApiClientConstants.notifyHost
        )
    }
}

extension BaseHosts {
    func url(for host: RouteHost) -> String {
        {
            switch host {
            case .api:
                return apiHost
            case .content:
                return contentHost
            case .notify:
                return notifyHost
            }
        }() + "/2"
    }
}
