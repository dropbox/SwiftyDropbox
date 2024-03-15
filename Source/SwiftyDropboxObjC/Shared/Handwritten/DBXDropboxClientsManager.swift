///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

@objc
public class DBXDropboxClientsManager: NSObject {
    /// An authorized client. This will be set to nil if unlinked.
    @objc
    public static var authorizedClient: DBXDropboxClient? {
        get {
            DropboxClientsManager.authorizedClient?.objc
        }
        set {
            DropboxClientsManager.authorizedClient = newValue?.subSwift
        }
    }

    /// An authorized background client. This will be set to nil if unlinked.
    @objc
    public static var authorizedBackgroundClient: DBXDropboxClient? {
        get {
            DropboxClientsManager.authorizedBackgroundClient?.objc
        }
        set {
            DropboxClientsManager.authorizedBackgroundClient = newValue?.subSwift
        }
    }

    /// Authorized background clients created in the course of handling background events from extensions, keyed by session identifiers.
    @objc
    public static var authorizedExtensionBackgroundClient: [String: DBXDropboxClient] {
        get {
            DropboxClientsManager.authorizedExtensionBackgroundClients.mapValues { client in
                client.objc
            }
        }
        set {
            DropboxClientsManager.authorizedExtensionBackgroundClients = newValue.mapValues { client in
                client.subSwift
            }
        }
    }

    /// An authorized team client. This will be set to nil if unlinked.
    @objc
    public static var authorizedTeamClient: DBXDropboxTeamClient? {
        get {
            DropboxClientsManager.authorizedTeamClient?.objc
        }
        set {
            DropboxClientsManager.authorizedTeamClient = newValue?.subSwift
        }
    }

    /// A sdk-caller provided logger for debugging.
    @objc
    public static var loggingClosure: ((DBXLogLevel, String) -> Void)? {
        get {
            { level, message in
                DropboxClientsManager.loggingClosure?(level.swift, message)
            }
        }
        set {
            DropboxClientsManager.loggingClosure = { level, message in
                newValue?(DBXLogLevel(logLevel: level), message)
            }
        }
    }

    /// The installed version of the SDK
    @objc
    public static var sdkVersion: String { DropboxClientsManager.sdkVersion }

    @objc
    public static func reauthorizeClient(_ tokenUid: String) {
        DropboxClientsManager.reauthorizeClient(tokenUid)
    }

    @objc
    public static func reauthorizeBackgroundClient(_ tokenUid: String, requestsToReconnect: @escaping ([DBXReconnectionResult]) -> Void) {
        DropboxClientsManager.reauthorizeBackgroundClient(tokenUid, requestsToReconnect: { swiftRequests in
            requestsToReconnect(objcRequests(from: swiftRequests))
        })
    }

    @objc
    public static func reauthorizeTeamClient(_ tokenUid: String) {
        DropboxClientsManager.reauthorizeTeamClient(tokenUid)
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    ///
    /// - parameters:
    ///     - url: The URL to attempt to handle.
    ///     - includeBackgroundClient: additionally auth background client.
    ///     - completion: The callback closure to receive auth result.
    /// - returns: Whether the redirect URL can be handled.
    @objc
    @discardableResult
    public static func handleRedirectURL(_ url: URL, includeBackgroundClient: Bool, completion: @escaping (DBXDropboxOAuthResult?) -> Void) -> Bool {
        DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: includeBackgroundClient, completion: bridgeDropboxOAuthCompletion(completion))
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    ///
    /// - parameters:
    ///     - url: The URL to attempt to handle.
    ///     - includeBackgroundClient: additionally auth background client.
    ///     - transportClient: A custom transport client to use for network requests.
    ///     - backgroundSessionTransportClient: A custom transport client to use for background network requests.
    ///     - sessionConfiguration: A custom session configuration to use for network requests.
    ///     - backgroundSessionConfiguration: A custom session configuration to use for background network requests.
    ///     - completion: The callback closure to receive auth result.
    /// - returns: Whether the redirect URL can be handled.
    @objc
    @discardableResult
    public static func handleRedirectURL(
        _ url: URL,
        includeBackgroundClient: Bool,
        transportClient: DBXDropboxTransportClient?,
        backgroundSessionTransportClient: DBXDropboxTransportClient?,
        sessionConfiguration: DBXNetworkSessionConfiguration?,
        backgroundSessionConfiguration: DBXNetworkSessionConfiguration?,
        completion: @escaping (DBXDropboxOAuthResult?) -> Void
    ) -> Bool {
        DropboxClientsManager.handleRedirectURL(
            url,
            includeBackgroundClient: includeBackgroundClient,
            transportClient: transportClient?.swift,
            backgroundSessionTransportClient: backgroundSessionTransportClient?.swift,
            sessionConfiguration: sessionConfiguration?.swift,
            backgroundSessionConfiguration: backgroundSessionConfiguration?.swift,
            completion: bridgeDropboxOAuthCompletion(completion)
        )
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    ///
    /// - parameters:
    ///     - url: The URL to attempt to handle.
    ///     - transportClient: A custom transport client to use for network requests.
    ///     - sessionConfiguration: A custom session configuration to use for network requests.
    ///     - completion: The callback closure to receive auth result.
    /// - returns: Whether the redirect URL can be handled.
    @objc
    @discardableResult
    public static func handleRedirectURLTeam(
        _ url: URL,
        transportClient: DBXDropboxTransportClient?,
        sessionConfiguration: DBXNetworkSessionConfiguration?,
        completion: @escaping (DBXDropboxOAuthResult?) -> Void
    ) -> Bool {
        DropboxClientsManager.handleRedirectURLTeam(
            url,
            transportClient: transportClient?.swift,
            sessionConfiguration: sessionConfiguration?.swift,
            completion: bridgeDropboxOAuthCompletion(completion)
        )
    }

    /// Prepare the appropriate single user DropboxClient to handle incoming background session events and make ongoing tasks available for reconnection
    ///
    /// - parameters:
    ///     - identifier: The identifier of the URLSession for which events must be handled.
    ///     - creationInfos: Information to configure extension DropboxClients in the event that they must be recreated in the main app to handle events.
    ///     - completionHandler: The completion handler to be executed when the underlying URLSessionDelegate recieves urlSessionDidFinishEvents(forBackgroundURLSession:).
    ///     - requestsToReconnect: The callback closure to receive requests for reconnection.
    @objc
    public static func handleEventsForBackgroundURLSession(
        with identifier: String,
        creationInfos: [DBXBackgroundExtensionSessionCreationInfo],
        completionHandler: @escaping () -> Void,
        requestsToReconnect: @escaping ([DBXReconnectionResult]) -> Void
    ) {
        DropboxClientsManager.handleEventsForBackgroundURLSession(
            with: identifier,
            creationInfos: creationInfos.map(\.swift),
            completionHandler: completionHandler,
            requestsToReconnect: { swiftRequests in
                requestsToReconnect(objcRequests(from: swiftRequests))
            }
        )
    }

    /// Prepare the appropriate multiuser DropboxClient to handle incoming background session events and make ongoing tasks available for reconnection
    ///
    /// - parameters:
    ///     - identifier: The identifier of the URLSession for which events must be handled.
    ///     - tokenUid: The uid of the token to authenticate this client with.
    ///     - creationInfos: Information to configure extension DropboxClients in the event that they must be recreated in the main app to handle events.
    ///     - completionHandler: The completion handler to be executed when the underlying URLSessionDelegate recieves urlSessionDidFinishEvents(forBackgroundURLSession:).
    ///     - requestsToReconnect: The callback closure to receive requests for reconnection.
    @objc
    public static func handleEventsForBackgroundURLSessionMultiUser(
        with identifier: String,
        tokenUid: String,
        creationInfos: [DBXBackgroundExtensionSessionCreationInfo],
        completionHandler: @escaping () -> Void,
        requestsToReconnect: @escaping ([DBXReconnectionResult]) -> Void
    ) {
        DropboxClientsManager.handleEventsForBackgroundURLSessionMultiUser(
            with: identifier,
            tokenUid: tokenUid,
            creationInfos: creationInfos.map(\.swift),
            completionHandler: completionHandler,
            requestsToReconnect: { swiftRequests in
                requestsToReconnect(objcRequests(from: swiftRequests))
            }
        )
    }

    static func objcRequests(from swiftRequests: [Result<DropboxBaseRequestBox, ReconnectionError>]) -> [DBXReconnectionResult] {
        swiftRequests.map { swiftRequest in
            switch swiftRequest {
            case .success(let box):
                return DBXReconnectionResult(request: box.objc, error: nil)
            case .failure(let error):
                return DBXReconnectionResult(request: nil, error: error.objc)
            }
        }
    }

    /// Unlink the user.
    @objc
    public static func unlinkClients() {
        DropboxClientsManager.unlinkClients()
    }

    /// Unlink the user.
    @objc
    public static func resetClients() {
        DropboxClientsManager.resetClients()
    }

    /// Logs to the provided logging closure
    @objc
    public static func log(_ level: DBXLogLevel, _ message: String) {
        DropboxClientsManager.log(level.swift, message)
    }

    /// Logs to the provided logging closure with background session tag and log level.
    @objc
    public static func logBackgroundSession(_ message: String) {
        DropboxClientsManager.logBackgroundSession(message)
    }

    /// Logs to the provided logging closure with background session tag.
    @objc
    public static func logBackgroundSession(_ level: DBXLogLevel, _ message: String) {
        DropboxClientsManager.logBackgroundSession(level.swift, message)
    }
}

// MARK: Bridging helpers

@objc
public enum DBXLogLevel: Int {
    public typealias RawValue = Int

    case error
    case info
    case debug

    var swift: LogLevel {
        switch self {
        case .error:
            return .error
        case .info:
            return .info
        case .debug:
            return .debug
        }
    }

    init(logLevel: LogLevel) {
        switch logLevel {
        case .error:
            self = .error
        case .info:
            self = .info
        case .debug:
            self = .debug
        }
    }
}
