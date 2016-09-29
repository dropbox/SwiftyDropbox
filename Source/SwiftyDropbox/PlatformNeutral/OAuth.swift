///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import SystemConfiguration
import Foundation

public protocol SharedApplication {
    func presentErrorMessage(_ message: String, title: String)
    func presentErrorMessageWithHandlers(_ message: String, title: String, buttonHandlers: Dictionary<String, () -> Void>)
    func presentPlatformSpecificAuth(_ authURL: URL) -> Bool
    func presentWebViewAuth(_ authURL: URL, tryIntercept: @escaping ((URL) -> Bool), cancelHandler: @escaping (() -> Void))
    func presentBrowserAuth(_ authURL: URL)
    func presentExternalApp(_ url: URL)
    func canPresentExternalApp(_ url: URL) -> Bool
}


open class DropboxDesktopOAuthManager: DropboxOAuthManager {}


open class DropboxMobileOAuthManager: DropboxOAuthManager {
    var dauthRedirectURL: URL

    public override init(appKey: String, host: String) {
        self.dauthRedirectURL = URL(string: "db-\(appKey)://1/connect")!
        super.init(appKey: appKey, host:host)
        self.urls.append(self.dauthRedirectURL)
    }

    internal override func extractFromUrl(_ url: URL) -> DropboxOAuthResult {
        let result: DropboxOAuthResult
        if url.host == "1" { // dauth
            result = extractfromDAuthURL(url)
        } else {
            result = extractFromRedirectURL(url)
        }
        return result
    }

    internal override func checkAndPresentPlatformSpecificAuth(_ sharedApplication: SharedApplication) -> Bool {
        if !self.hasApplicationQueriesSchemes() {
            let message = "DropboxSDK: unable to link; app isn't registered to query for URL schemes dbapi-2 and dbapi-8-emm. Add a dbapi-2 entry and a dbapi-8-emm entry to LSApplicationQueriesSchemes"
            let title = "SwiftyDropbox Error"
            sharedApplication.presentErrorMessage(message, title: title)
            return true
        }

        if let scheme = dAuthScheme(sharedApplication) {
            let nonce = UUID().uuidString
            UserDefaults.standard.set(nonce, forKey: kDBLinkNonce)
            UserDefaults.standard.synchronize()
            sharedApplication.presentExternalApp(dAuthURL(scheme, nonce: nonce))
            return true
        }
        return false
    }

    fileprivate func dAuthURL(_ scheme: String, nonce: String?) -> URL {
        var components = URLComponents()
        components.scheme =  scheme
        components.host = "1"
        components.path = "/connect"

        if let n = nonce {
            let state = "oauth2:\(n)"
            components.queryItems = [
                URLQueryItem(name: "k", value: self.appKey),
                URLQueryItem(name: "s", value: ""),
                URLQueryItem(name: "state", value: state),
            ]
        }
        return components.url!
    }

    fileprivate func dAuthScheme(_ sharedApplication: SharedApplication) -> String? {
        if sharedApplication.canPresentExternalApp(dAuthURL("dbapi-2", nonce: nil)) {
            return "dbapi-2"
        } else if sharedApplication.canPresentExternalApp(dAuthURL("dbapi-8-emm", nonce: nil)) {
            return "dbapi-8-emm"
        } else {
            return nil
        }
    }

    func extractfromDAuthURL(_ url: URL) -> DropboxOAuthResult {
        switch url.path {
        case "/connect":
            var results = [String: String]()
            let pairs  = url.query?.components(separatedBy: "&") ?? []

            for pair in pairs {
                let kv = pair.components(separatedBy: "=")
                results.updateValue(kv[1], forKey: kv[0])
            }
            let state = results["state"]?.components(separatedBy: "%3A") ?? []

            let nonce = UserDefaults.standard.object(forKey: kDBLinkNonce) as? String
            if state.count == 2 && state[0] == "oauth2" && state[1] == nonce! {
                let accessToken = results["oauth_token_secret"]!
                let uid = results["uid"]!
                return .success(DropboxAccessToken(accessToken: accessToken, uid: uid))
            } else {
                return .error(.unknown, "Unable to verify link request")
            }
        default:
            return .error(.accessDenied, "User cancelled Dropbox link")
        }
    }

    fileprivate func hasApplicationQueriesSchemes() -> Bool {
        let queriesSchemes = Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String] ?? []

        var foundApi2 = false
        var foundApi8Emm = false
        for scheme in queriesSchemes {
            if scheme == "dbapi-2" {
                foundApi2 = true
            } else if scheme == "dbapi-8-emm" {
                foundApi8Emm = true
            }
            if foundApi2 && foundApi8Emm {
                return true
            }
        }
        return false
    }
}


/// Manages access token storage and authentication
///
/// Use the `DropboxOAuthManager` to authenticate users through OAuth2, save access tokens, and retrieve access tokens.
open class DropboxOAuthManager {
    let appKey: String
    let redirectURL: URL
    let host: String
    var urls: Array<URL>

    // MARK: Shared instance
    /// A shared instance of a `DropboxOAuthManager` for convenience
    open static var sharedOAuthManager: DropboxOAuthManager!

    // MARK: Functions
    public init(appKey: String, host: String) {
        self.appKey = appKey
        self.redirectURL = URL(string: "db-\(self.appKey)://2/token")!
        self.host = host
        self.urls = [self.redirectURL]
    }

    ///
    /// Create an instance
    /// parameter appKey: The app key from the developer console that identifies this app.
    ///
    convenience public init(appKey: String) {
        self.init(appKey: appKey, host: "www.dropbox.com")
    }

    ///
    /// Try to handle a redirect back into the application
    ///
    /// - parameter url: The URL to attempt to handle
    ///
    /// - returns `nil` if SwiftyDropbox cannot handle the redirect URL, otherwise returns the `DropboxOAuthResult`.
    ///
    open func handleRedirectURL(_ url: URL) -> DropboxOAuthResult? {
        // check if url is a cancel url
        if (url.host == "1" && url.path == "/cancel") || (url.host == "2" && url.path == "/cancel") {
            return .cancel
        }

        if !self.canHandleURL(url) {
            return nil
        }

        let result = extractFromUrl(url)

        switch result {
        case .success(let token):
            _ = Keychain.set(token.uid, value: token.accessToken)
            return result
        default:
            return result
        }
    }

    ///
    /// Present the OAuth2 authorization request page by presenting a web view controller modally
    ///
    /// - parameter controller: The controller to present from
    ///
    open func authorizeFromSharedApplication(_ sharedApplication: SharedApplication, browserAuth: Bool = false) {
        if !Reachability.connectedToNetwork() {
            let message = "Try again once you have an internet connection"
            let title = "No internet connection"

            let buttonHandlers: [String: () -> Void] = [
                "Retry": { self.authorizeFromSharedApplication(sharedApplication) },
            ]
            sharedApplication.presentErrorMessageWithHandlers(message, title: title, buttonHandlers: buttonHandlers)

            return
        }

        if !self.conformsToAppScheme() {
            let message = "DropboxSDK: unable to link; app isn't registered for correct URL scheme (db-\(self.appKey)). Add this scheme to your project Info.plist file, under \"URL types\" > \"URL Schemes\"."
            let title = "SwiftyDropbox Error"

            sharedApplication.presentErrorMessage(message, title:title)

            return
        }

        let url = self.authURL()

        if checkAndPresentPlatformSpecificAuth(sharedApplication) {
            return
        }

        if browserAuth {
            sharedApplication.presentBrowserAuth(url)
        } else {
            let tryIntercept: ((URL) -> Bool) = { url in
                if self.canHandleURL(url) {
                    sharedApplication.presentExternalApp(url)
                    return true
                } else {
                    return false
                }
            }

            let cancelHandler: (() -> Void) = {
                let cancelUrl = URL(string: "db-\(self.appKey)://2/cancel")!
                sharedApplication.presentExternalApp(cancelUrl)
            }

            sharedApplication.presentWebViewAuth(url, tryIntercept: tryIntercept, cancelHandler: cancelHandler)
        }
    }

    fileprivate func conformsToAppScheme() -> Bool {
        let appScheme = "db-\(self.appKey)"

        let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [ [String: AnyObject] ] ?? []

        for urlType in urlTypes {
            let schemes = urlType["CFBundleURLSchemes"] as? [String] ?? []
            for scheme in schemes {
                if scheme == appScheme {
                    return true
                }
            }
        }
        return false
    }

    func authURL() -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.host
        components.path = "/1/oauth2/authorize"

        components.queryItems = [
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "client_id", value: self.appKey),
            URLQueryItem(name: "redirect_uri", value: self.redirectURL.absoluteString),
            URLQueryItem(name: "disable_signup", value: "true"),
        ]
        return components.url!
    }

    fileprivate func canHandleURL(_ url: URL) -> Bool {
        for known in self.urls {
            if url.scheme == known.scheme && url.host == known.host && url.path == known.path {
                return true
            }
        }
        return false
    }

    func extractFromRedirectURL(_ url: URL) -> DropboxOAuthResult {
        var results = [String: String]()
        let pairs  = url.fragment?.components(separatedBy: "&") ?? []

        for pair in pairs {
            let kv = pair.components(separatedBy: "=")
            results.updateValue(kv[1], forKey: kv[0])
        }

        if let error = results["error"] {
            let desc = results["error_description"]?.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
            if results["error"]! == "access_denied" {
                return .cancel
            }
            return .error(OAuth2Error(errorCode: error), desc ?? "")
        } else {
            let accessToken = results["access_token"]!
            let uid = results["uid"]!
            return .success(DropboxAccessToken(accessToken: accessToken, uid: uid))
        }
    }

    func extractFromUrl(_ url: URL) -> DropboxOAuthResult {
        return extractFromRedirectURL(url)
    }

    func checkAndPresentPlatformSpecificAuth(_ sharedApplication: SharedApplication) -> Bool {
        return false
    }

    ///
    /// Retrieve all stored access tokens
    ///
    /// - returns: a dictionary mapping users to their access tokens
    ///
    open func getAllAccessTokens() -> [String : DropboxAccessToken] {
        let users = Keychain.getAll()
        var ret = [String : DropboxAccessToken]()
        for user in users {
            if let accessToken = Keychain.get(user) {
                ret[user] = DropboxAccessToken(accessToken: accessToken, uid: user)
            }
        }
        return ret
    }

    ///
    /// Check if there are any stored access tokens
    ///
    /// - returns: Whether there are stored access tokens
    ///
    open func hasStoredAccessTokens() -> Bool {
        return self.getAllAccessTokens().count != 0
    }

    ///
    /// Retrieve the access token for a particular user
    ///
    /// - parameter user: The user whose token to retrieve
    ///
    /// - returns: An access token if present, otherwise `nil`.
    ///
    open func getAccessToken(_ user: String?) -> DropboxAccessToken? {
        if let user = user {
            if let accessToken = Keychain.get(user) {
                return DropboxAccessToken(accessToken: accessToken, uid: user)
            }
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
    open func clearStoredAccessToken(_ token: DropboxAccessToken) -> Bool {
        return Keychain.delete(token.uid)
    }

    ///
    /// Delete all stored access tokens
    ///
    /// - returns: whether the operation succeeded
    ///
    open func clearStoredAccessTokens() -> Bool {
        return Keychain.clear()
    }

    ///
    /// Save an access token
    ///
    /// - parameter token: The access token to save
    ///
    /// - returns: whether the operation succeeded
    ///
    open func storeAccessToken(_ token: DropboxAccessToken) -> Bool {
        return Keychain.set(token.uid, value: token.accessToken)
    }

    ///
    /// Utility function to return an arbitrary access token
    ///
    /// - returns: the "first" access token found, if any (otherwise `nil`)
    ///
    open func getFirstAccessToken() -> DropboxAccessToken? {
        return self.getAllAccessTokens().values.first
    }
}

/// A Dropbox access token
open class DropboxAccessToken: CustomStringConvertible {

    /// The access token string
    open let accessToken: String

    /// The associated user
    open let uid: String

    public init(accessToken: String, uid: String) {
        self.accessToken = accessToken
        self.uid = uid
    }

    open var description: String {
        return self.accessToken
    }
}

/// A failed authorization.
/// See RFC6749 4.2.2.1
public enum OAuth2Error {
    /// The client is not authorized to request an access token using this method.
    case unauthorizedClient

    /// The resource owner or authorization server denied the request.
    case accessDenied

    /// The authorization server does not support obtaining an access token using this method.
    case unsupportedResponseType

    /// The requested scope is invalid, unknown, or malformed.
    case invalidScope

    /// The authorization server encountered an unexpected condition that prevented it from fulfilling the request.
    case serverError

    /// The authorization server is currently unable to handle the request due to a temporary overloading or maintenance of the server.
    case temporarilyUnavailable

    /// Some other error (outside of the OAuth2 specification)
    case unknown

    /// Initializes an error code from the string specced in RFC6749
    init(errorCode: String) {
        switch errorCode {
            case "unauthorized_client": self = .unauthorizedClient
            case "access_denied": self = .accessDenied
            case "unsupported_response_type": self = .unsupportedResponseType
            case "invalid_scope": self = .invalidScope
            case "server_error": self = .serverError
            case "temporarily_unavailable": self = .temporarilyUnavailable
            default: self = .unknown
        }
    }
}

internal let kDBLinkNonce = "dropbox.sync.nonce"

/// The result of an authorization attempt.
public enum DropboxOAuthResult {
    /// The authorization succeeded. Includes a `DropboxAccessToken`.
    case success(DropboxAccessToken)

    /// The authorization failed. Includes an `OAuth2Error` and a descriptive message.
    case error(OAuth2Error, String)

    /// The authorization was manually canceled by the user.
    case cancel
}

class Keychain {

    class func queryWithDict(_ query: [String : AnyObject]) -> CFDictionary {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        var queryDict = query

        queryDict[kSecClass as String]       = kSecClassGenericPassword
        queryDict[kSecAttrService as String] = "\(bundleId).dropbox.authv2" as AnyObject?

        return queryDict as CFDictionary
    }

    class func set(_ key: String, value: String) -> Bool {
        if let data = value.data(using: String.Encoding.utf8) {
            return set(key, value: data)
        } else {
            return false
        }
    }

    class func set(_ key: String, value: Data) -> Bool {
        let query = Keychain.queryWithDict([
            (kSecAttrAccount as String): key as AnyObject,
            (  kSecValueData as String): value as AnyObject
        ])

        SecItemDelete(query)

        return SecItemAdd(query, nil) == noErr
    }

    class func getAsData(_ key: String) -> Data? {
        let query = Keychain.queryWithDict([
            (kSecAttrAccount as String): key as AnyObject,
            ( kSecReturnData as String): kCFBooleanTrue,
            ( kSecMatchLimit as String): kSecMatchLimitOne
        ])

        var dataResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataResult)

        if status == noErr {
            return dataResult as? Data
        }

        return nil
    }

    class func getAll() -> [String] {
        let query = Keychain.queryWithDict([
            ( kSecReturnAttributes as String): kCFBooleanTrue,
            (       kSecMatchLimit as String): kSecMatchLimitAll
        ])

        var dataResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataResult)

        if status == noErr {
            let results = dataResult as? [[String : AnyObject]] ?? []
            return results.map { d in d["acct"] as! String }

        }
        return []
    }



    class func get(_ key: String) -> String? {
        if let data = getAsData(key) {
            return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
        } else {
            return nil
        }
    }

    class func delete(_ key: String) -> Bool {
        let query = Keychain.queryWithDict([
            (kSecAttrAccount as String): key as AnyObject
        ])

        return SecItemDelete(query) == noErr
    }

    class func clear() -> Bool {
        let query = Keychain.queryWithDict([:])
        return SecItemDelete(query) == noErr
    }
}

class Reachability {
    /// From http://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647.
    ///
    /// This method uses `SCNetworkReachabilityCreateWithAddress` to create a reference to monitor the example host
    /// defined by our zeroed `zeroAddress` struct. From this reference, we can extract status flags regarding the
    /// reachability of this host, using `SCNetworkReachabilityGetFlags`.

    class func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
