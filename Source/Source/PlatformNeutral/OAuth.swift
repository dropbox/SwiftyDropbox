//import Security
import SystemConfiguration
import Foundation

public protocol SharedApplication {
    func presentErrorMessage(message: String, title: String)
    func presentErrorMessageWithHandlers(message: String, title: String, buttonHandlers: Dictionary<String, () -> Void>)
    func presentPlatformSpecificAuth(authURL: NSURL) -> Bool
    func presentWebViewAuth(authURL: NSURL, tryIntercept: (NSURL -> Bool), cancelHandler: (() -> Void))
    func presentBrowserAuth(authURL: NSURL)
    func presentExternalApp(url: NSURL)
    func canPresentExternalApp(url: NSURL) -> Bool
}


public class DropboxDesktopAuthManager: DropboxAuthManager {}


public class DropboxMobileAuthManager: DropboxAuthManager {
    var dauthRedirectURL: NSURL

    public override init(appKey: String, host: String) {
        self.dauthRedirectURL = NSURL(string: "db-\(appKey)://1/connect")!
        super.init(appKey: appKey, host:host)
        self.urls.append(self.dauthRedirectURL)
    }

    internal override func extractFromUrl(url: NSURL) -> DropboxAuthResult {
        let result: DropboxAuthResult
        if url.host == "1" { // dauth
            result = extractfromDAuthURL(url)
        } else {
            result = extractFromRedirectURL(url)
        }
        return result
    }

    internal override func checkAndPresentPlatformSpecificAuth(sharedApplication: SharedApplication) -> Bool {
        if !self.hasApplicationQueriesSchemes() {
            let message = "DropboxSDK: unable to link; app isn't registered to query for URL schemes dbapi-2 and dbapi-8-emm. Add a dbapi-2 entry and a dbapi-8-emm entry to LSApplicationQueriesSchemes"
            let title = "SwiftyDropbox Error"
            sharedApplication.presentErrorMessage(message, title: title)
            return true
        }

        if let scheme = dAuthScheme(sharedApplication) {
            let nonce = NSUUID().UUIDString
            NSUserDefaults.standardUserDefaults().setObject(nonce, forKey: kDBLinkNonce)
            NSUserDefaults.standardUserDefaults().synchronize()
            sharedApplication.presentExternalApp(dAuthURL(scheme, nonce: nonce))
            return true
        }
        return false
    }

    private func dAuthURL(scheme: String, nonce: String?) -> NSURL {
        let components = NSURLComponents()
        components.scheme =  scheme
        components.host = "1"
        components.path = "/connect"

        if let n = nonce {
            let state = "oauth2:\(n)"
            components.queryItems = [
                NSURLQueryItem(name: "k", value: self.appKey),
                NSURLQueryItem(name: "s", value: ""),
                NSURLQueryItem(name: "state", value: state),
            ]
        }
        return components.URL!
    }

    private func dAuthScheme(sharedApplication: SharedApplication) -> String? {
        if sharedApplication.canPresentExternalApp(dAuthURL("dbapi-2", nonce: nil)) {
            return "dbapi-2"
        } else if sharedApplication.canPresentExternalApp(dAuthURL("dbapi-8-emm", nonce: nil)) {
            return "dbapi-8-emm"
        } else {
            return nil
        }
    }

    func extractfromDAuthURL(url: NSURL) -> DropboxAuthResult {
        switch url.path ?? "" {
        case "/connect":
            var results = [String: String]()
            let pairs  = url.query?.componentsSeparatedByString("&") ?? []

            for pair in pairs {
                let kv = pair.componentsSeparatedByString("=")
                results.updateValue(kv[1], forKey: kv[0])
            }
            let state = results["state"]?.componentsSeparatedByString("%3A") ?? []

            let nonce = NSUserDefaults.standardUserDefaults().objectForKey(kDBLinkNonce) as? String
            if state.count == 2 && state[0] == "oauth2" && state[1] == nonce! {
                let accessToken = results["oauth_token_secret"]!
                let uid = results["uid"]!
                return .Success(DropboxAccessToken(accessToken: accessToken, uid: uid))
            } else {
                return .Error(.Unknown, "Unable to verify link request")
            }
        default:
            return .Error(.AccessDenied, "User cancelled Dropbox link")
        }
    }

    private func hasApplicationQueriesSchemes() -> Bool {
        let queriesSchemes = NSBundle.mainBundle().objectForInfoDictionaryKey("LSApplicationQueriesSchemes") as? [String] ?? []

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
/// Use the `DropboxAuthManager` to authenticate users through OAuth2, save access tokens, and retrieve access tokens.
public class DropboxAuthManager {
    let appKey: String
    let redirectURL: NSURL
    let host: String
    var urls: Array<NSURL>

    // MARK: Shared instance
    /// A shared instance of a `DropboxAuthManager` for convenience
    public static var sharedAuthManager: DropboxAuthManager!

    // MARK: Functions
    public init(appKey: String, host: String) {
        self.appKey = appKey
        self.redirectURL = NSURL(string: "db-\(self.appKey)://2/token")!
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
    /// - returns `nil` if SwiftyDropbox cannot handle the redirect URL, otherwise returns the `DropboxAuthResult`.
    ///
    public func handleRedirectURL(url: NSURL) -> DropboxAuthResult? {
        // check if url is a cancel url
        if (url.host == "1" && url.path == "/cancel") || (url.host == "2" && url.path == "/cancel") {
            return .Cancel
        }

        if !self.canHandleURL(url) {
            return nil
        }

        let result = extractFromUrl(url)

        switch result {
        case .Success(let token):
            Keychain.set(token.uid, value: token.accessToken)
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
    public func authorizeFromSharedApplication(sharedApplication: SharedApplication, browserAuth: Bool = false) {
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
            let tryIntercept: (NSURL -> Bool) = { url in
                if self.canHandleURL(url) {
                    sharedApplication.presentExternalApp(url)
                    return true
                } else {
                    return false
                }
            }

            let cancelHandler: (() -> Void) = {
                let cancelUrl = NSURL(string: "db-\(self.appKey)://2/cancel")!
                sharedApplication.presentExternalApp(cancelUrl)
            }

            sharedApplication.presentWebViewAuth(url, tryIntercept: tryIntercept, cancelHandler: cancelHandler)
        }
    }

    private func conformsToAppScheme() -> Bool {
        let appScheme = "db-\(self.appKey)"

        let urlTypes = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleURLTypes") as? [ [String: AnyObject] ] ?? []

        for urlType in urlTypes {
            let schemes = urlType["CFBundleURLSchemes"] as? [String] ?? []
            for scheme in schemes {
                print(scheme)
                if scheme == appScheme {
                    return true
                }
            }
        }
        return false
    }

    func authURL() -> NSURL {
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = self.host
        components.path = "/1/oauth2/authorize"

        components.queryItems = [
            NSURLQueryItem(name: "response_type", value: "token"),
            NSURLQueryItem(name: "client_id", value: self.appKey),
            NSURLQueryItem(name: "redirect_uri", value: self.redirectURL.URLString),
            NSURLQueryItem(name: "disable_signup", value: "true"),
        ]
        return components.URL!
    }

    private func canHandleURL(url: NSURL) -> Bool {
        for known in self.urls {
            if url.scheme == known.scheme && url.host == known.host && url.path == known.path {
                return true
            }
        }
        return false
    }

    func extractFromRedirectURL(url: NSURL) -> DropboxAuthResult {
        var results = [String: String]()
        let pairs  = url.fragment?.componentsSeparatedByString("&") ?? []

        for pair in pairs {
            let kv = pair.componentsSeparatedByString("=")
            results.updateValue(kv[1], forKey: kv[0])
        }

        if let error = results["error"] {
            let desc = results["error_description"]?.stringByReplacingOccurrencesOfString("+", withString: " ").stringByRemovingPercentEncoding
            if results["error"]! == "access_denied" {
                return .Cancel
            }
            return .Error(OAuth2Error(errorCode: error), desc ?? "")
        } else {
            let accessToken = results["access_token"]!
            let uid = results["account_id"] ?? results["team_id"]!
            return .Success(DropboxAccessToken(accessToken: accessToken, uid: uid))
        }
    }

    func extractFromUrl(url: NSURL) -> DropboxAuthResult {
        return extractFromRedirectURL(url)
    }

    func checkAndPresentPlatformSpecificAuth(sharedApplication: SharedApplication) -> Bool {
        return false
    }

    ///
    /// Retrieve all stored access tokens
    ///
    /// - returns: a dictionary mapping users to their access tokens
    ///
    public func getAllAccessTokens() -> [String : DropboxAccessToken] {
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
    public func hasStoredAccessTokens() -> Bool {
        return self.getAllAccessTokens().count != 0
    }

    ///
    /// Retrieve the access token for a particular user
    ///
    /// - parameter user: The user whose token to retrieve
    ///
    /// - returns: An access token if present, otherwise `nil`.
    ///
    public func getAccessToken(user: String) -> DropboxAccessToken? {
        if let accessToken = Keychain.get(user) {
            return DropboxAccessToken(accessToken: accessToken, uid: user)
        } else {
            return nil
        }
    }

    ///
    /// Delete a specific access token
    ///
    /// - parameter token: The access token to delete
    ///
    /// - returns: whether the operation succeeded
    ///
    public func clearStoredAccessToken(token: DropboxAccessToken) -> Bool {
        return Keychain.delete(token.uid)
    }

    ///
    /// Delete all stored access tokens
    ///
    /// - returns: whether the operation succeeded
    ///
    public func clearStoredAccessTokens() -> Bool {
        return Keychain.clear()
    }

    ///
    /// Save an access token
    ///
    /// - parameter token: The access token to save
    ///
    /// - returns: whether the operation succeeded
    ///
    public func storeAccessToken(token: DropboxAccessToken) -> Bool {
        return Keychain.set(token.uid, value: token.accessToken)
    }

    ///
    /// Utility function to return an arbitrary access token
    ///
    /// - returns: the "first" access token found, if any (otherwise `nil`)
    ///
    public func getFirstAccessToken() -> DropboxAccessToken? {
        return self.getAllAccessTokens().values.first
    }
}

/// A Dropbox access token
public class DropboxAccessToken: CustomStringConvertible {

    /// The access token string
    public let accessToken: String

    /// The associated user
    public let uid: String

    public init(accessToken: String, uid: String) {
        self.accessToken = accessToken
        self.uid = uid
    }

    public var description: String {
        return self.accessToken
    }
}

/// A failed authorization.
/// See RFC6749 4.2.2.1
public enum OAuth2Error {
    /// The client is not authorized to request an access token using this method.
    case UnauthorizedClient

    /// The resource owner or authorization server denied the request.
    case AccessDenied

    /// The authorization server does not support obtaining an access token using this method.
    case UnsupportedResponseType

    /// The requested scope is invalid, unknown, or malformed.
    case InvalidScope

    /// The authorization server encountered an unexpected condition that prevented it from fulfilling the request.
    case ServerError

    /// The authorization server is currently unable to handle the request due to a temporary overloading or maintenance of the server.
    case TemporarilyUnavailable

    /// Some other error (outside of the OAuth2 specification)
    case Unknown

    /// Initializes an error code from the string specced in RFC6749
    init(errorCode: String) {
        switch errorCode {
            case "unauthorized_client": self = .UnauthorizedClient
            case "access_denied": self = .AccessDenied
            case "unsupported_response_type": self = .UnsupportedResponseType
            case "invalid_scope": self = .InvalidScope
            case "server_error": self = .ServerError
            case "temporarily_unavailable": self = .TemporarilyUnavailable
            default: self = .Unknown
        }
    }
}

internal let kDBLinkNonce = "dropbox.sync.nonce"

/// The result of an authorization attempt.
public enum DropboxAuthResult {
    /// The authorization succeeded. Includes a `DropboxAccessToken`.
    case Success(DropboxAccessToken)

    /// The authorization failed. Includes an `OAuth2Error` and a descriptive message.
    case Error(OAuth2Error, String)

    /// The authorization was manually canceled by the user.
    case Cancel
}

class Keychain {

    class func queryWithDict(query: [String : AnyObject]) -> CFDictionaryRef {
        let bundleId = NSBundle.mainBundle().bundleIdentifier ?? ""
        var queryDict = query

        queryDict[kSecClass as String]       = kSecClassGenericPassword
        queryDict[kSecAttrService as String] = "\(bundleId).dropbox.authv2"

        return queryDict
    }

    class func set(key: String, value: String) -> Bool {
        if let data = value.dataUsingEncoding(NSUTF8StringEncoding) {
            return set(key, value: data)
        } else {
            return false
        }
    }

    class func set(key: String, value: NSData) -> Bool {
        let query = Keychain.queryWithDict([
            (kSecAttrAccount as String): key,
            (  kSecValueData as String): value
        ])

        SecItemDelete(query)

        return SecItemAdd(query, nil) == noErr
    }

    class func getAsData(key: String) -> NSData? {
        let query = Keychain.queryWithDict([
            (kSecAttrAccount as String): key,
            ( kSecReturnData as String): kCFBooleanTrue,
            ( kSecMatchLimit as String): kSecMatchLimitOne
        ])

        var dataResult: AnyObject?
        let status = withUnsafeMutablePointer(&dataResult) { (ptr) in
            SecItemCopyMatching(query, UnsafeMutablePointer(ptr))
        }

        if status == noErr {
            return dataResult as? NSData
        }

        return nil
    }

    class func dbgListAllItems() {
        let query: CFDictionaryRef = [
            (kSecClass as String)           : kSecClassGenericPassword,
            (kSecReturnAttributes as String): kCFBooleanTrue,
            (       kSecMatchLimit as String): kSecMatchLimitAll
        ]

        var dataResult: AnyObject?
        let status = withUnsafeMutablePointer(&dataResult) { (ptr) in
            SecItemCopyMatching(query, UnsafeMutablePointer(ptr))
        }

        if status == noErr {
            let results = dataResult as? [[String : AnyObject]] ?? []

            print(results.map {d in (d["svce"] as! String, d["acct"] as! String)})
        }

    }

    class func getAll() -> [String] {
        let query = Keychain.queryWithDict([
            ( kSecReturnAttributes as String): kCFBooleanTrue,
            (       kSecMatchLimit as String): kSecMatchLimitAll
        ])

        var dataResult: AnyObject?
        let status = withUnsafeMutablePointer(&dataResult) { (ptr) in
            SecItemCopyMatching(query, UnsafeMutablePointer(ptr))
        }

        if status == noErr {
            let results = dataResult as? [[String : AnyObject]] ?? []
            return results.map { d in d["acct"] as! String }

        }
        return []
    }



    class func get(key: String) -> String? {
        if let data = getAsData(key) {
            return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        } else {
            return nil
        }
    }

    class func delete(key: String) -> Bool {
        let query = Keychain.queryWithDict([
            (kSecAttrAccount as String): key
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
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
}
