//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

/// Manages access token storage and authentication
///
/// Use the `DropboxOAuthManager` to authenticate users through OAuth2, save access tokens, and retrieve access tokens.
///
/// @note OAuth flow webviews localize to enviroment locale.
///
public class DropboxOAuthManager: AccessTokenRefreshing {
    public let locale: Locale?
    let appKey: String
    let redirectURL: URL
    let host: String
    var urls: [URL]
    /// Session data for OAuth2 code flow with PKCE.
    /// nil if we are in the legacy token flow.
    var authSession: OAuthPKCESession?
    weak var sharedApplication: SharedApplication?

    private var connectedToNetwork: () -> Bool = { Reachability.connectedToNetwork() }
    private var bundleURLTypes: [[String: AnyObject]]

    private var localeIdentifier: String {
        locale?.identifier ?? (Bundle.main.preferredLocalizations.first ?? "en")
    }

    // MARK: Shared instance

    /// A shared instance of a `DropboxOAuthManager` for convenience
    public static var sharedOAuthManager: DropboxOAuthManager!

    private let networkSession: NetworkSession
    private let secureStorageAccess: SecureStorageAccess

    // MARK: Functions

    init(
        appKey: String,
        host: String,
        secureStorageAccess: SecureStorageAccess,
        networkSession: NetworkSession
    ) {
        self.appKey = appKey
        self.redirectURL = URL(string: "db-\(self.appKey)://2/token")!
        self.host = host
        self.urls = [redirectURL]
        self.locale = nil
        self.secureStorageAccess = secureStorageAccess
        self.networkSession = networkSession
        self.bundleURLTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: AnyObject]] ?? []
    }

    public convenience init(
        appKey: String,
        host: String,
        secureStorageAccess: SecureStorageAccess
    ) {
        self.init(appKey: appKey, host: host, secureStorageAccess: secureStorageAccess, networkSession: URLSession(configuration: .default))
    }

    ///
    /// Create an instance
    /// parameter appKey: The app key from the developer console that identifies this app.
    ///
    public convenience init(appKey: String, secureStorageAccess: SecureStorageAccess) {
        self.init(appKey: appKey, host: "www.dropbox.com", secureStorageAccess: secureStorageAccess)
    }

    ///
    /// Try to handle a redirect back into the application
    ///
    /// - parameters:
    ///     - url: The URL to attempt to handle.
    ///     - completion: The callback closure to receive auth result.
    /// - returns: Whether the redirect URL can be handled.
    ///
    public func handleRedirectURL(_ url: URL, completion: @escaping DropboxOAuthCompletion) -> Bool {
        // check if url is a cancel url
        if (url.host == "1" && url.path == "/cancel") || (url.host == "2" && url.path == "/cancel") {
            completion(.cancel)
            return true
        }
        if canHandleURL(url) {
            extractFromUrl(url) { result in
                if case let .success(token) = result {
                    self.storeAccessToken(token)
                }
                completion(result)
            }
            return true
        } else {
            completion(nil)
            return false
        }
    }

    ///
    /// Present the OAuth2 authorization request page by presenting a web view controller modally.
    ///
    /// - parameters:
    ///     - controller: The controller to present from.
    ///     - usePKCE: Whether to use OAuth2 code flow with PKCE. Default is false, i.e. use the legacy token flow.
    ///     - scopeRequest: The ScopeRequest, only used in code flow with PKCE.
    public func authorizeFromSharedApplication(
        _ sharedApplication: SharedApplication, usePKCE: Bool = false, scopeRequest: ScopeRequest? = nil
    ) {
        let cancelHandler: (() -> Void) = {
            let cancelUrl = URL(string: "db-\(self.appKey)://2/cancel")!
            sharedApplication.presentExternalApp(cancelUrl)
        }

        if !connectedToNetwork() {
            let message = "Try again once you have an internet connection"
            let title = "No internet connection"

            let buttonHandlers: [String: () -> Void] = [
                "Cancel": { cancelHandler() },
                "Retry": { self.authorizeFromSharedApplication(sharedApplication, usePKCE: usePKCE, scopeRequest: scopeRequest) },
            ]
            sharedApplication.presentErrorMessageWithHandlers(message, title: title, buttonHandlers: buttonHandlers)

            return
        }

        if !conformsToAppScheme() {
            let message =
                "DropboxSDK: unable to link; app isn't registered for correct URL scheme (db-\(appKey)). Add this scheme to your project Info.plist file, under \"URL types\" > \"URL Schemes\"."
            let title = "SwiftyDropbox Error"

            sharedApplication.presentErrorMessage(message, title: title)

            return
        }

        if usePKCE {
            authSession = OAuthPKCESession(scopeRequest: scopeRequest)
        } else {
            authSession = nil
        }
        self.sharedApplication = sharedApplication

        let url = authURL()

        if checkAndPresentPlatformSpecificAuth(sharedApplication) {
            return
        }

        let tryIntercept: ((URL) -> Bool) = { url in
            if self.canHandleURL(url) {
                sharedApplication.presentExternalApp(url)
                return true
            } else {
                return false
            }
        }
        sharedApplication.presentAuthChannel(url, tryIntercept: tryIntercept, cancelHandler: cancelHandler)
    }

    fileprivate func conformsToAppScheme() -> Bool {
        let appScheme = "db-\(appKey)"

        for urlType in bundleURLTypes {
            let schemes = urlType["CFBundleURLSchemes"] as? [String] ?? []
            for scheme in schemes {
                if scheme == appScheme {
                    return true
                }
            }
        }
        return false
    }

    fileprivate func authURL() -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/oauth2/authorize"

        var params = [
            URLQueryItem(name: "client_id", value: appKey),
            URLQueryItem(name: "redirect_uri", value: redirectURL.absoluteString),
            URLQueryItem(name: "disable_signup", value: "true"),
            URLQueryItem(name: "locale", value: localeIdentifier),
        ]

        if let authSession = authSession {
            // Code flow.
            params.append(contentsOf: OAuthUtils.createPkceCodeFlowParams(for: authSession))
        } else {
            // Token flow.
            params.append(URLQueryItem(name: OAuthConstants.responseTypeKey, value: "token"))
        }
        // used to prevent malicious impersonation of app from web browser
        let state = ProcessInfo.processInfo.globallyUniqueString
        UserDefaults.standard.setValue(state, forKey: Constants.kCSRFKey)
        params.append(URLQueryItem(name: OAuthConstants.stateKey, value: state))

        components.queryItems = params
        guard let url = components.url else { fatalError("Failed to create auth url.") }
        return url
    }

    fileprivate func canHandleURL(_ url: URL) -> Bool {
        for known in urls {
            if url.scheme == known.scheme && url.host == known.host && url.path == known.path {
                return true
            }
        }
        return false
    }

    /// Handles redirect URL from web.
    /// Auth results are passed back in URL query parameters.
    /// - Error result parameters looks like this:
    /// ```
    /// [
    ///     "error": "<error_name>",
    ///     "error_description: "<error_description>"
    /// ]
    /// ```
    /// - Success result looks like these:
    ///     1. Code flow result
    ///     ```
    ///     [
    ///         "state": "<state_string>",
    ///         "code": "<oauth_code>"
    ///     ]
    ///     ```
    ///     2. Token flow result
    ///     ```
    ///     [
    ///         "state": "<state_string>",
    ///         "access_token": "<oauth2_access_token>",
    ///         "uid": "<uid>"
    ///     ]
    ///     ```
    func extractFromRedirectURL(_ url: URL, completion: @escaping DropboxOAuthCompletion) {
        let parametersMap: [String: String]
        let isInOAuthCodeFlow = authSession != nil
        if isInOAuthCodeFlow {
            parametersMap = OAuthUtils.extractOAuthResponseFromCodeFlowUrl(url)
        } else {
            parametersMap = OAuthUtils.extractOAuthResponseFromTokenFlowUrl(url)
        }
        // Error case
        if let error = parametersMap[OAuthConstants.errorKey] {
            let result: DropboxOAuthResult
            if error == OAuth2Error.accessDenied.rawValue {
                // Treat as cancelled if user denied auth.
                result = .cancel
            } else {
                let description = parametersMap[OAuthConstants.errorDescription]
                result = .error(OAuth2Error(errorCode: error), description)
            }
            completion(result)
        } else {
            // Success case
            let state = parametersMap[OAuthConstants.stateKey]
            let storedState = UserDefaults.standard.string(forKey: Constants.kCSRFKey)

            // State from redirect URL should match stored state.
            guard state != nil, storedState != nil, state == storedState else {
                completion(
                    .error(
                        OAuth2Error(errorCode: "inconsistent_state"), "Auth flow failed because of inconsistent state."
                    )
                )
                return
            }
            // Reset state upon success
            UserDefaults.standard.setValue(nil, forKey: Constants.kCSRFKey)

            if let authSession = authSession, let authCode = parametersMap["code"] {
                // Code flow.
                finishPkceOAuth(
                    authCode: authCode, codeVerifier: authSession.pkceData.codeVerifier, completion: completion
                )
            } else if let accessToken = parametersMap["access_token"], let uid = parametersMap[OAuthConstants.uidKey] {
                // Token flow.
                completion(.success(DropboxAccessToken(accessToken: accessToken, uid: uid)))
            } else {
                completion(.error(.unknown, "Invalid response."))
            }
        }
    }

    func extractFromUrl(_ url: URL, completion: @escaping DropboxOAuthCompletion) {
        extractFromRedirectURL(url, completion: completion)
    }

    func finishPkceOAuth(authCode: String, codeVerifier: String, completion: @escaping DropboxOAuthCompletion) {
        sharedApplication?.presentLoading()
        let request = OAuthTokenExchangeRequest(
            dataTaskCreation: networkSession.dataTask(request:networkTaskTag:completionHandler:),
            oauthCode: authCode, codeVerifier: codeVerifier,
            appKey: appKey, locale: localeIdentifier, redirectUri: redirectURL.absoluteString
        )
        request.start(queue: DispatchQueue.main) { [weak sharedApplication] in
            sharedApplication?.dismissLoading()
            completion($0)
        }
    }

    func checkAndPresentPlatformSpecificAuth(_ sharedApplication: SharedApplication) -> Bool {
        false
    }

    ///
    /// Retrieve all stored access tokens
    ///
    /// - returns: a dictionary mapping users to their access tokens
    ///
    public func getAllAccessTokens() -> [String: DropboxAccessToken] {
        let users = secureStorageAccess.getAllUserIds()
        var ret = [String: DropboxAccessToken]()
        for user in users {
            if let accessToken = secureStorageAccess.getDropboxAccessToken(for: user) {
                ret[user] = accessToken
            }
        }
        return ret
    }

    ///
    /// Check if there are any stored access tokens
    ///
    /// - returns: Whether there are stored access tokens
    ///
    public func hasStoredAccessTokens() -> Bool {
        getAllAccessTokens().count != 0
    }

    ///
    /// Retrieve the access token for a particular user
    ///
    /// - parameter user: The user whose token to retrieve
    ///
    /// - returns: An access token if present, otherwise `nil`.
    ///
    public func getAccessToken(_ user: String?) -> DropboxAccessToken? {
        if let user = user {
            return secureStorageAccess.getDropboxAccessToken(for: user)
        }
        return nil
    }

    ///
    /// Delete a specific access token
    ///
    /// - parameter token: The access token to delete
    ///
    /// - returns: whether the operation succeeded
    ///
    public func clearStoredAccessToken(_ token: DropboxAccessToken) -> Bool {
        secureStorageAccess.deleteInfo(for: token.uid)
    }

    ///
    /// Delete all stored access tokens
    ///
    /// - returns: whether the operation succeeded
    ///
    public func clearStoredAccessTokens() -> Bool {
        secureStorageAccess.deleteInfoForAllKeys()
    }

    ///
    /// Save an access token
    ///
    /// - parameter token: The access token to save
    ///
    /// - returns: whether the operation succeeded
    ///
    @discardableResult
    public func storeAccessToken(_ token: DropboxAccessToken) -> Bool {
        do {
            let jsonEncoder = JSONEncoder()
            let data = try jsonEncoder.encode(token)
            return secureStorageAccess.setAccessTokenData(for: token.uid, data: data)
        } catch {
            return false
        }
    }

    ///
    /// Utility function to return an arbitrary access token
    ///
    /// - returns: the "first" access token found, if any (otherwise `nil`)
    ///
    public func getFirstAccessToken() -> DropboxAccessToken? {
        getAllAccessTokens().values.first
    }

    // MARK: Short-lived token support.

    /// Refreshes a (short-lived) access token for a given DropboxAccessToken.
    ///
    /// - Parameters:
    ///     - accessToken: A `DropboxAccessToken` object.
    ///     - scopes: An array of scopes to be granted for the refreshed access token.
    ///       The requested scope MUST NOT include any scope not originally granted.
    ///       Useful if users want to reduce the granted scopes for the new access token.
    ///       Pass in an empty array if you don't want to change scopes of the access token.
    ///     - queue: The queue where completion block will be called from.
    ///     - completion: A `DropboxOAuthCompletion` block to notify caller the result.
    ///
    /// - NOTE: Completion block will be called on main queue if a callback queue is not provided.
    public func refreshAccessToken(
        _ accessToken: DropboxAccessToken,
        scopes: [String],
        queue: DispatchQueue?,
        completion: @escaping DropboxOAuthCompletion
    ) {
        guard let refreshToken = accessToken.refreshToken else {
            completion(.error(.unknown, "Long-lived token can't be refreshed."))
            return
        }
        let uid = accessToken.uid
        let refreshRequest = OAuthTokenRefreshRequest(
            dataTaskCreation: networkSession.dataTask(request:networkTaskTag:completionHandler:),
            uid: uid, refreshToken: refreshToken, scopes: scopes, appKey: appKey, locale: localeIdentifier
        )
        refreshRequest.start(queue: DispatchQueue.main) { [weak self] result in
            if case let .success(token) = result {
                self?.storeAccessToken(token)
            }
            (queue ?? DispatchQueue.main).async { completion(result) }
        }
    }

    /// Creates an `AccessTokenProvider` that wraps short-lived for token refresh
    /// or a static provider for long-live token.
    /// - Parameter token: The `DropboxAccessToken` object.
    public func accessTokenProviderForToken(_ token: DropboxAccessToken) -> AccessTokenProvider {
        if token.isShortLivedToken {
            return ShortLivedAccessTokenProvider(token: token, tokenRefresher: self)
        } else {
            return LongLivedAccessTokenProvider(accessToken: token.accessToken)
        }
    }

    func checkAccessibilityMigrationOneTime() {
        secureStorageAccess.checkAccessibilityMigrationOneTime()
    }
}

extension DropboxOAuthManager {
    func __test_only_setConnectedToNetwork(value: Bool) {
        connectedToNetwork = { value }
    }

    func __test_only_setBundleURLTypes(value: [[String: AnyObject]]) {
        bundleURLTypes = value
    }
}
