///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation

public typealias RequestsToReconnect = ([Result<DropboxBaseRequestBox, ReconnectionError>]) -> Void

/// This is a convenience class for the typical single user case. To use this
/// class, see details in the tutorial at:
/// https://www.dropbox.com/developers/documentation/swift#tutorial
///
/// For information on the available API methods, see the documentation for DropboxClient
public class DropboxClientsManager {
    /// An authorized client. This will be set to nil if unlinked.
    public static var authorizedClient: DropboxClient?

    /// An authorized background client. This will be set to nil if unlinked.
    public static var authorizedBackgroundClient: DropboxClient?

    /// Authorized background clients created in the course of handling background events from extensions, keyed by session identifiers.
    public static var authorizedExtensionBackgroundClients: [String: DropboxClient] = [:]

    /// An authorized team client. This will be set to nil if unlinked.
    public static var authorizedTeamClient: DropboxTeamClient?

    /// A sdk-caller provided logger
    public static var loggingClosure: LoggingClosure?

    /// The installed version of the SDK
    public static var sdkVersion: String {
        Constants.versionSDK
    }

    struct OAuthSetupContext {
        enum UserKind {
            case single
            case multi(tokenUid: String?)
        }

        var userKind: UserKind
        var isTeam: Bool
        var includeBackgroundClient: Bool
    }

    static func setupWithOAuthManager(
        _ appKey: String, oAuthManager: DropboxOAuthManager,
        transportClient: DropboxTransportClient?,
        backgroundTransportClient: DropboxTransportClient? = nil,
        oauthSetupIntent: OAuthSetupContext,
        requestsToReconnect: RequestsToReconnect? = nil
    ) {
        precondition(
            DropboxOAuthManager.sharedOAuthManager == nil,
            "Only call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` once"
        )
        DropboxOAuthManager.sharedOAuthManager = oAuthManager

        if let token = token(for: oauthSetupIntent.userKind, using: oAuthManager) {
            setUpAuthorizedClient(
                token: token,
                transportClient: transportClient,
                backgroundTransportClient: backgroundTransportClient,
                sessionConfiguration: nil,
                backgroundSessionConfiguration: nil,
                oAuthManager: oAuthManager,
                oauthSetupIntent: oauthSetupIntent,
                requestsToReconnect: requestsToReconnect
            )
        }

        checkAccessibilityMigrationOneTime(oauthManager: oAuthManager)
    }

    static func setupWithOAuthManager(
        _ appKey: String,
        oAuthManager: DropboxOAuthManager,
        sessionConfiguration: NetworkSessionConfiguration? = nil,
        backgroundSessionConfiguration: NetworkSessionConfiguration? = nil,
        oauthSetupIntent: OAuthSetupContext,
        requestsToReconnect: RequestsToReconnect? = nil
    ) {
        precondition(
            DropboxOAuthManager.sharedOAuthManager == nil,
            "Only call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` once"
        )
        DropboxOAuthManager.sharedOAuthManager = oAuthManager

        if let token = token(for: oauthSetupIntent.userKind, using: oAuthManager) {
            setUpAuthorizedClient(
                token: token,
                transportClient: nil,
                backgroundTransportClient: nil,
                sessionConfiguration: sessionConfiguration,
                backgroundSessionConfiguration: backgroundSessionConfiguration,
                oAuthManager: oAuthManager,
                oauthSetupIntent: oauthSetupIntent,
                requestsToReconnect: requestsToReconnect
            )
        }

        checkAccessibilityMigrationOneTime(oauthManager: oAuthManager)
    }

    private static func token(for userKind: OAuthSetupContext.UserKind, using oAuthManager: DropboxOAuthManager) -> DropboxAccessToken? {
        switch userKind {
        case .single:
            return oAuthManager.getFirstAccessToken()
        case .multi(tokenUid: let tokenUid):
            return oAuthManager.getAccessToken(tokenUid)
        }
    }

    private static func setUpAuthorizedClient(
        token: DropboxAccessToken,
        transportClient: DropboxTransportClient?,
        backgroundTransportClient: DropboxTransportClient?,
        sessionConfiguration: NetworkSessionConfiguration?,
        backgroundSessionConfiguration: NetworkSessionConfiguration?,
        oAuthManager: DropboxOAuthManager,
        oauthSetupIntent: OAuthSetupContext,
        requestsToReconnect: RequestsToReconnect?
    ) {
        if oauthSetupIntent.isTeam {
            setupAuthorizedTeamClient(token, transportClient: transportClient, sessionConfiguration: sessionConfiguration)
        } else {
            setupAuthorizedClient(token, transportClient: transportClient, sessionConfiguration: sessionConfiguration)

            if oauthSetupIntent.includeBackgroundClient {
                guard let requestsToReconnect = requestsToReconnect else {
                    assertionFailure("Cannot initialize a background session withouth a request reconnection block")
                    return
                }
                setupAuthorizedBackgroundClient(
                    token,
                    transportClient: backgroundTransportClient,
                    sessionConfiguration: backgroundSessionConfiguration,
                    requestsToReconnect: requestsToReconnect
                )
            }
        }
    }

    public static func reauthorizeClient(
        _ tokenUid: String,
        transportClient: DropboxTransportClient? = nil,
        sessionConfiguration: NetworkSessionConfiguration? = nil
    ) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        if let token = DropboxOAuthManager.sharedOAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedClient(token, transportClient: transportClient, sessionConfiguration: sessionConfiguration)
        }
        checkAccessibilityMigrationOneTime(oauthManager: DropboxOAuthManager.sharedOAuthManager)
    }

    public static func reauthorizeBackgroundClient(
        _ tokenUid: String,
        transportClient: DropboxTransportClient? = nil,
        sessionConfiguration: NetworkSessionConfiguration? = nil,
        requestsToReconnect: @escaping RequestsToReconnect
    ) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        if let token = DropboxOAuthManager.sharedOAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedBackgroundClient(
                token,
                transportClient: transportClient,
                sessionConfiguration: sessionConfiguration,
                requestsToReconnect: requestsToReconnect
            )
        }
        checkAccessibilityMigrationOneTime(oauthManager: DropboxOAuthManager.sharedOAuthManager)
    }

    public static func reauthorizeTeamClient(
        _ tokenUid: String,
        transportClient: DropboxTransportClient? = nil,
        sessionConfiguration: NetworkSessionConfiguration? = nil
    ) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        if let token = DropboxOAuthManager.sharedOAuthManager.getAccessToken(tokenUid) {
            setupAuthorizedTeamClient(token, transportClient: transportClient, sessionConfiguration: sessionConfiguration)
        }
        checkAccessibilityMigrationOneTime(oauthManager: DropboxOAuthManager.sharedOAuthManager)
    }

    static func setupAuthorizedClient(
        _ accessToken: DropboxAccessToken?,
        transportClient: DropboxTransportClient?,
        sessionConfiguration: NetworkSessionConfiguration?
    ) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        if let sessionConfiguration = sessionConfiguration {
            assert(transportClient == nil, "sessionConfiguration will be unused if a transportClient is already being passed.")
            if case .background = sessionConfiguration.kind {
                assertionFailure("Cannot use a background session configuration for non-background clients")
                return
            }
        }

        if let accessToken = accessToken, let oauthManager = DropboxOAuthManager.sharedOAuthManager {
            let accessTokenProvider = oauthManager.accessTokenProviderForToken(accessToken)
            if var transportClient = transportClient {
                transportClient.accessTokenProvider = accessTokenProvider
                authorizedClient = DropboxClient(transportClient: transportClient)
            } else {
                authorizedClient = DropboxClient(accessTokenProvider: accessTokenProvider, sessionConfiguration: sessionConfiguration)
            }
        } else {
            if let transportClient = transportClient {
                authorizedClient = DropboxClient(transportClient: transportClient)
            }
        }
    }

    static func setupAuthorizedBackgroundClient(
        _ accessToken: DropboxAccessToken?,
        transportClient: DropboxTransportClient?,
        sessionConfiguration: NetworkSessionConfiguration?,
        requestsToReconnect: @escaping ([Result<DropboxBaseRequestBox, ReconnectionError>]) -> Void
    ) {
        authorizedBackgroundClient = authorizedBackgroundClient(
            accessToken,
            transportClient: transportClient,
            sessionConfiguration: sessionConfiguration,
            isExtensionClient: false
        )

        // If a background session is recreated while it's running requests from a previous session
        // AppDelegate.handleEventsForBackgroundURLSession will never be called. We check for requests
        // to reconnect when a background session is created to handle this case.
        authorizedBackgroundClient?.getAllRequests(completion: { requests in
            requestsToReconnect(requests)
        })
    }

    static func setupAuthorizedBackgroundExtensionClient(
        _ accessToken: DropboxAccessToken?,
        transportClient: DropboxTransportClient?,
        sessionConfiguration: NetworkSessionConfiguration?
    ) {
        guard let identifier = sessionConfiguration?.identifier else {
            assertionFailure("Must provide a background session configuration to create a background client")
            return
        }

        authorizedExtensionBackgroundClients[identifier] = authorizedBackgroundClient(
            accessToken,
            transportClient: transportClient,
            sessionConfiguration: sessionConfiguration,
            isExtensionClient: true
        )
    }

    private static func authorizedBackgroundClient(
        _ accessToken: DropboxAccessToken?,
        transportClient: DropboxTransportClient?,
        sessionConfiguration: NetworkSessionConfiguration?,
        isExtensionClient: Bool
    ) -> DropboxClient? {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        if let sessionConfiguration = sessionConfiguration {
            assert(transportClient == nil, "sessionConfiguration will be unused if a transportClient is already being passed.")
            guard case .background = sessionConfiguration.kind else {
                assertionFailure("Must use a background session configuration for background clients")
                return nil
            }
        }

        var authorizedBackgroundClient: DropboxClient?

        if let accessToken = accessToken, let oauthManager = DropboxOAuthManager.sharedOAuthManager {
            let accessTokenProvider = oauthManager.accessTokenProviderForToken(accessToken)
            if var transportClient = transportClient {
                transportClient.accessTokenProvider = accessTokenProvider
                authorizedBackgroundClient = DropboxClient(transportClient: transportClient)
            } else {
                let fallbackConfiguration = {
                    let bundleId = Bundle.main.bundleIdentifier ?? "unknown_bundle_id"
                    let fallbackConfigurationId = "\(bundleId).SwiftyDropbox.backgroundSession"
                    return NetworkSessionConfiguration(kind: .background(fallbackConfigurationId))
                }

                let sessionConfiguration = sessionConfiguration ?? fallbackConfiguration()
                let transportClient = DropboxTransportClientImpl(
                    accessTokenProvider: accessTokenProvider,
                    userAgent: nil,
                    selectUser: nil,
                    sessionConfiguration: sessionConfiguration
                )
                authorizedBackgroundClient = DropboxClient(transportClient: transportClient)
            }
        } else {
            if let transportClient = transportClient {
                authorizedBackgroundClient = DropboxClient(transportClient: transportClient)
            }
        }

        return authorizedBackgroundClient
    }

    static func setupAuthorizedTeamClient(
        _ accessToken: DropboxAccessToken?,
        transportClient: DropboxTransportClient?,
        sessionConfiguration: NetworkSessionConfiguration?
    ) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        if let sessionConfiguration = sessionConfiguration {
            assert(transportClient == nil, "sessionConfiguration will be unused if a transportClient is already being passed.")
            if case .background = sessionConfiguration.kind {
                assertionFailure("Cannot use a background session configuration for team clients")
                return
            }
        }

        if let accessToken = accessToken, let oauthManager = DropboxOAuthManager.sharedOAuthManager {
            let accessTokenProvider = oauthManager.accessTokenProviderForToken(accessToken)
            if var transportClient = transportClient {
                transportClient.accessTokenProvider = accessTokenProvider
                authorizedTeamClient = DropboxTeamClient(transportClient: transportClient)
            } else {
                authorizedTeamClient = DropboxTeamClient(accessTokenProvider: accessTokenProvider, sessionConfiguration: sessionConfiguration)
            }
        } else {
            if let transportClient = transportClient {
                authorizedTeamClient = DropboxTeamClient(transportClient: transportClient)
            }
        }
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    ///
    /// - parameters:
    ///     - url: The URL to attempt to handle.
    ///     - includeBackgroundClient: Whether to additionally initialize an authorized background client.
    ///     - completion: The callback closure to receive auth result.
    /// - returns: Whether the redirect URL can be handled.
    ///
    @discardableResult
    public static func handleRedirectURL(
        _ url: URL,
        includeBackgroundClient: Bool,
        transportClient: DropboxTransportClient? = nil,
        backgroundSessionTransportClient: DropboxTransportClient? = nil,
        sessionConfiguration: NetworkSessionConfiguration? = nil,
        backgroundSessionConfiguration: NetworkSessionConfiguration? = nil,
        completion: @escaping DropboxOAuthCompletion
    ) -> Bool {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")
        return DropboxOAuthManager.sharedOAuthManager.handleRedirectURL(url, completion: { result in
            if let result = result {
                switch result {
                case .success(let accessToken):
                    setupAuthorizedClient(accessToken, transportClient: transportClient, sessionConfiguration: sessionConfiguration)

                    if includeBackgroundClient {
                        setupAuthorizedBackgroundClient(
                            accessToken,
                            transportClient: backgroundSessionTransportClient,
                            sessionConfiguration: backgroundSessionConfiguration,
                            requestsToReconnect: { _ in } // No need for reconnect as no loads are in progress pre-auth
                        )
                    }
                case .cancel, .error:
                    break
                }
            }
            completion(result)
        })
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    ///
    /// - parameters:
    ///     - url: The URL to attempt to handle.
    ///     - backgroundSessionIdentifier: The URLSession identifier to use for the background client
    ///     - sharedContainerIdentifier: The URLSessionConfiguration shared container identifier to use for the background client
    ///     - completion: The callback closure to receive auth result.
    /// - returns: Whether the redirect URL can be handled.
    ///
    @discardableResult
    public static func handleRedirectURL(
        _ url: URL,
        backgroundSessionIdentifier: String,
        sharedContainerIdentifier: String? = nil,
        completion: @escaping DropboxOAuthCompletion
    ) -> Bool {
        let backgroundNetworkSessionConfiguration = NetworkSessionConfiguration.background(
            withIdentifier: backgroundSessionIdentifier,
            sharedContainerIdentifier: sharedContainerIdentifier
        )
        return handleRedirectURL(
            url,
            includeBackgroundClient: true,
            backgroundSessionConfiguration: backgroundNetworkSessionConfiguration,
            completion: completion
        )
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    ///
    /// - parameters:
    ///     - url: The URL to attempt to handle.
    ///     - completion: The callback closure to receive auth result.
    /// - returns: Whether the redirect URL can be handled.
    ///
    @discardableResult
    public static func handleRedirectURLTeam(
        _ url: URL,
        transportClient: DropboxTransportClient? = nil,
        sessionConfiguration: NetworkSessionConfiguration? = nil,
        completion: @escaping DropboxOAuthCompletion
    ) -> Bool {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithTeamAppKey` before calling this method")
        return DropboxOAuthManager.sharedOAuthManager.handleRedirectURL(url, completion: { result in
            if let result = result {
                switch result {
                case .success(let accessToken):
                    setupAuthorizedTeamClient(accessToken, transportClient: transportClient, sessionConfiguration: sessionConfiguration)
                case .cancel, .error:
                    break
                }
            }
            completion(result)
        })
    }

    /// Prepare the appropriate single user DropboxClient to handle incoming background session events and make ongoing tasks available for reconnection
    ///
    /// - parameters:
    ///     - identifier: The identifier of the URLSession for which events must be handled.
    ///     - creationInfos: Information to configure extension DropboxClients in the event that they must be recreated in the main app to handle events.
    ///     - completionHandler: The completion handler to be executed when the underlying URLSessionDelegate recieves urlSessionDidFinishEvents(forBackgroundURLSession:).
    ///     - requestsToReconnect: The callback closure to receive requests for reconnection.
    public static func handleEventsForBackgroundURLSession(
        with identifier: String,
        creationInfos: [BackgroundExtensionSessionCreationInfo],
        completionHandler: @escaping () -> Void,
        requestsToReconnect: @escaping ([Result<DropboxBaseRequestBox, ReconnectionError>]) -> Void
    ) {
        _handleEventsForBackgroundURLSession(
            with: identifier,
            tokenUid: nil,
            creationInfos: creationInfos,
            completionHandler: completionHandler,
            requestsToReconnect: requestsToReconnect
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
    public static func handleEventsForBackgroundURLSessionMultiUser(
        with identifier: String,
        tokenUid: String,
        creationInfos: [BackgroundExtensionSessionCreationInfo],
        completionHandler: @escaping () -> Void,
        requestsToReconnect: @escaping ([Result<DropboxBaseRequestBox, ReconnectionError>]) -> Void
    ) {
        _handleEventsForBackgroundURLSession(
            with: identifier,
            tokenUid: tokenUid,
            creationInfos: creationInfos,
            completionHandler: completionHandler,
            requestsToReconnect: requestsToReconnect
        )
    }

    private static func _handleEventsForBackgroundURLSession(
        with identifier: String,
        tokenUid: String?,
        creationInfos: [BackgroundExtensionSessionCreationInfo],
        completionHandler: @escaping () -> Void,
        requestsToReconnect: @escaping ([Result<DropboxBaseRequestBox, ReconnectionError>]) -> Void
    ) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` before calling this method")

        let handleEvents: (DropboxClient) -> Void = { client in
            client.didFinishBackgroundEvents = completionHandler

            client.getAllRequests(completion: { requests in
                requestsToReconnect(requests)
            })
        }

        let accessToken: DropboxAccessToken?

        if let tokenUid = tokenUid {
            accessToken = token(for: .multi(tokenUid: tokenUid), using: DropboxOAuthManager.sharedOAuthManager)
        } else {
            accessToken = token(for: .single, using: DropboxOAuthManager.sharedOAuthManager)
        }

        if let client = DropboxClientsManager.authorizedBackgroundClient, client.identifier == identifier {
            // The main app background session should already exist, handle events.
            handleEvents(client)
        } else {
            // For extension background sessions, recreate, store, then handle events.
            let creationInfo = creationInfos.first(where: { $0.identifier == identifier })

            guard let creationInfo = creationInfo else {
                return DropboxClientsManager.logBackgroundSession(
                    .error,
                    "handleEventsForBackgroundURLSession recieved background identifier without session creation information"
                )
            }

            if let defaultInfo = creationInfo.defaultInfo {
                let backgroundNetworkSessionConfiguration = NetworkSessionConfiguration.background(
                    withIdentifier: defaultInfo.backgroundSessionIdentifier,
                    sharedContainerIdentifier: defaultInfo.sharedContainerIdentifier
                )
                setupAuthorizedBackgroundExtensionClient(accessToken, transportClient: nil, sessionConfiguration: backgroundNetworkSessionConfiguration)
            }

            if let customInfo = creationInfo.customInfo {
                setupAuthorizedBackgroundExtensionClient(
                    accessToken,
                    transportClient: customInfo.backgroundTransportClient,
                    sessionConfiguration: customInfo.backgroundSessionConfiguration
                )
            }

            if let client = authorizedExtensionBackgroundClients[identifier] {
                handleEvents(client)
            } else {
                DropboxClientsManager.logBackgroundSession(.error, "handleEventsForBackgroundURLSession extension client creation failed")
            }
        }
    }

    /// Unlink the user.
    public static func unlinkClients() {
        if let oAuthManager = DropboxOAuthManager.sharedOAuthManager {
            _ = oAuthManager.clearStoredAccessTokens()
            resetClients()
        }
    }

    /// Unlink the user.
    public static func resetClients() {
        if DropboxClientsManager.authorizedClient == nil
            && DropboxClientsManager.authorizedTeamClient == nil
            && DropboxClientsManager.authorizedBackgroundClient == nil
            && DropboxClientsManager.authorizedExtensionBackgroundClients.isEmpty {
            // already unlinked
            return
        }

        DropboxClientsManager.authorizedClient = nil
        DropboxClientsManager.authorizedBackgroundClient = nil
        DropboxClientsManager.authorizedExtensionBackgroundClients = [:]
        DropboxClientsManager.authorizedTeamClient = nil
    }

    /// Logs to the provided logging closure
    public static func log(_ level: LogLevel, _ message: String) {
        LogHelper.log(level, message)
    }

    /// Logs to the provided logging closure with background session tag and log level.
    public static func logBackgroundSession(_ message: String) {
        LogHelper.logBackgroundSession(message)
    }

    /// Logs to the provided logging closure with background session tag.
    public static func logBackgroundSession(_ level: LogLevel, _ message: String) {
        LogHelper.logBackgroundSession(level, message)
    }

    private static func checkAccessibilityMigrationOneTime(oauthManager: DropboxOAuthManager) {
        oauthManager.checkAccessibilityMigrationOneTime()
    }
}
