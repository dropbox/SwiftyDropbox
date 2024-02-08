//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

public enum ReconnectionErrorKind: String, Error {
    case noPersistedInfo
    case versionMismatch
    case badPersistedStringFormat
    case missingReconnectionCase
    case unknown
}

public struct ReconnectionError: Error {
    public let reconnectionErrorKind: ReconnectionErrorKind
    public let taskDescription: String?
}

protocol PersistedRequestInfoBaseInfo {
    var originalSDKVersion: String { get }
    var routeName: String { get }
    var routeNamespace: String { get }
    var clientProvidedInfo: String? { get set }
}

private struct ReconnectionConstants {
    static let separator = "#?///?#"
}

protocol ReconnectionHelpersShared {
    static func persistedRequestInfo(from apiRequest: ApiRequest) throws -> ReconnectionHelpers.PersistedRequestInfo
    static func originalSdkVersion(fromJsonString jsonString: String) throws -> String
    static func rebuildRequest<ASerial: JSONSerializer, RSerial: JSONSerializer, ESerial: JSONSerializer>(
        apiRequest: ApiRequest,
        info: ReconnectionHelpers.PersistedRequestInfo,
        route: Route<ASerial, RSerial, ESerial>,
        client: DropboxTransportClientInternal
    ) -> UploadRequest<RSerial, ESerial>

    static func rebuildRequest<ASerial: JSONSerializer, RSerial: JSONSerializer, ESerial: JSONSerializer>(
        apiRequest: ApiRequest,
        info: ReconnectionHelpers.PersistedRequestInfo,
        route: Route<ASerial, RSerial, ESerial>,
        client: DropboxTransportClientInternal
    ) -> DownloadRequestFile<RSerial, ESerial>
}

extension ReconnectionHelpersShared {
    static func persistedRequestInfo(from apiRequest: ApiRequest) throws -> ReconnectionHelpers.PersistedRequestInfo {
        guard let taskDescription = apiRequest.taskDescription else {
            throw ReconnectionErrorKind.noPersistedInfo
        }
        guard try originalSdkVersion(fromJsonString: taskDescription) == DropboxClientsManager.sdkVersion else {
            throw ReconnectionErrorKind.versionMismatch
        }

        return try ReconnectionHelpers.PersistedRequestInfo.from(jsonString: taskDescription)
    }

    static func originalSdkVersion(fromJsonString jsonString: String) throws -> String {
        let components = jsonString.components(separatedBy: ReconnectionConstants.separator)
        guard components.count == 2 else {
            throw ReconnectionErrorKind.badPersistedStringFormat
        }
        return components[0]
    }

    static func rebuildRequest<ASerial: JSONSerializer, RSerial: JSONSerializer, ESerial: JSONSerializer>(
        apiRequest: ApiRequest,
        info: ReconnectionHelpers.PersistedRequestInfo,
        route: Route<ASerial, RSerial, ESerial>,
        client: DropboxTransportClientInternal
    ) -> UploadRequest<RSerial, ESerial> {
        if case .upload = info {
            return client.reconnectRequest(
                route,
                apiRequest: apiRequest
            )
        } else {
            fatalError("codegen error, background request not an upload or download file request")
        }
    }

    static func rebuildRequest<ASerial: JSONSerializer, RSerial: JSONSerializer, ESerial: JSONSerializer>(
        apiRequest: ApiRequest,
        info: ReconnectionHelpers.PersistedRequestInfo,
        route: Route<ASerial, RSerial, ESerial>,
        client: DropboxTransportClientInternal
    ) -> DownloadRequestFile<RSerial, ESerial> {
        if case .downloadFile(let info) = info {
            return client.reconnectRequest(
                route,
                apiRequest: apiRequest,
                overwrite: info.overwrite,
                destination: info.destination
            )
        } else {
            fatalError("codegen error, background request not an upload or download file request")
        }
    }
}

extension ReconnectionHelpers {
    enum PersistedRequestInfo: Codable, Equatable {
        case upload(StandardInfo)
        case downloadFile(DownloadFileInfo)

        struct StandardInfo: PersistedRequestInfoBaseInfo, Codable, Equatable {
            let originalSDKVersion: String
            let routeName: String
            let routeNamespace: String
            var clientProvidedInfo: String?
        }

        struct DownloadFileInfo: PersistedRequestInfoBaseInfo, Codable, Equatable {
            let originalSDKVersion: String
            let routeName: String
            let routeNamespace: String
            var clientProvidedInfo: String?
            let destination: URL
            let overwrite: Bool
        }

        func asJsonString() throws -> String {
            let jsonData = try JSONEncoder().encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8)

            // We encode the SDK Version outside of the JSON so we can condition JSON decoding on a version match
            return DropboxClientsManager.sdkVersion + ReconnectionConstants.separator + (try jsonString.orThrow())
        }

        static func from(jsonString: String) throws -> Self {
            let components = jsonString.components(separatedBy: ReconnectionConstants.separator)
            guard components.count == 2 else {
                throw ReconnectionErrorKind.badPersistedStringFormat
            }

            let jsonComponent = components[1]
            let jsonData = Data(jsonComponent.utf8)
            return try JSONDecoder().decode(Self.self, from: jsonData)
        }

        var routeName: String {
            switch self {
            case .upload(let info):
                return info.routeName
            case .downloadFile(let downloadInfo):
                return downloadInfo.routeName
            }
        }

        var clientProvidedInfo: String? {
            switch self {
            case .upload(let info):
                return info.clientProvidedInfo
            case .downloadFile(let downloadInfo):
                return downloadInfo.clientProvidedInfo
            }
        }

        mutating func settingClientInfo(string: String?) -> Self {
            switch self {
            case .upload(var info):
                info.clientProvidedInfo = string
                self = .upload(info)
            case .downloadFile(var downloadInfo):
                downloadInfo.clientProvidedInfo = string
                self = .downloadFile(downloadInfo)
            }
            return self
        }
    }
}
