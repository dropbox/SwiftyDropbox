import Foundation
import Alamofire

class DropboxServerTrustPolicyManager: ServerTrustPolicyManager {
    init() {
        super.init(policies: [String : ServerTrustPolicy]())
    }
        
    override func serverTrustPolicyForHost(host: String) -> ServerTrustPolicy? {
        let trustPolicy = ServerTrustPolicy.CustomEvaluation {(serverTrust, host) in
            let policy = SecPolicyCreateSSL(true,  host as CFString)
            SecTrustSetPolicies(serverTrust, [policy])
            
            let certificates = SecurityUtil.rootCertificates()
            SecTrustSetAnchorCertificates(serverTrust, certificates)
            SecTrustSetAnchorCertificatesOnly(serverTrust, true)
            
            var isValid = false
            var result = SecTrustResultType(kSecTrustResultInvalid)
            let status = SecTrustEvaluate(serverTrust, &result)
            
            if status == errSecSuccess {
                let unspecified = SecTrustResultType(kSecTrustResultUnspecified)
                let proceed = SecTrustResultType(kSecTrustResultProceed)
                
                isValid = result == unspecified || result == proceed
            }
            
            if (isValid) {
                let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
                isValid = !SecurityUtil.isRevokedCertificate(certificate)
            }
            
            return isValid

        }
        
        return trustPolicy
    }
}

/// This is a convenience class for the typical single user case. To use this
/// class, see details in the tutorial at:
/// https://www.dropbox.com/developers/documentation/swift#tutorial
///
/// For information on the available API methods, see the documentation for DropboxClient
public class Dropbox {
    /// An authorized client. This will be set to nil if unlinked.
    public static var authorizedClient: DropboxClient?
    
    /// An authorized team client. This will be set to nil if unlinked.
    public static var authorizedTeamClient: DropboxTeamClient?

    /// Sets up access to the Dropbox User API
    public static func setupWithAppKey(appKey: String) {
        precondition(DropboxAuthManager.sharedAuthManager == nil, "Only call `Dropbox.setupWithAppKey` or `Dropbox.setupWithTeamAppKey` once")
        DropboxAuthManager.sharedAuthManager = DropboxAuthManager(appKey: appKey)

        if let token = DropboxAuthManager.sharedAuthManager.getFirstAccessToken() {
            Dropbox.authorizedClient = DropboxClient(accessToken: token)
        }
    }
    
    /// Sets up access to the Dropbox Team API
    public static func setupWithTeamAppKey(appKey: String) {
        precondition(DropboxAuthManager.sharedAuthManager == nil, "Only call `Dropbox.setupWithAppKey` or `Dropbox.setupWithTeamAppKey` once")
        DropboxAuthManager.sharedAuthManager = DropboxAuthManager(appKey: appKey)
        
        if let token = DropboxAuthManager.sharedAuthManager.getFirstAccessToken() {
            Dropbox.authorizedTeamClient = DropboxTeamClient(accessToken: token)
        }
    }

    /// Present the OAuth2 authorization request page by presenting a web view controller modally
    ///
    /// - parameter controller: The controller to present from
    public static func authorizeFromController(controller: UIViewController) {
        precondition(DropboxAuthManager.sharedAuthManager != nil, "Call `Dropbox.setupWithAppKey` or `Dropbox.setupWithTeamAppKey` before calling this method")
        precondition(Dropbox.authorizedClient == nil && Dropbox.authorizedTeamClient == nil, "A Dropbox client is already authorized")
        DropboxAuthManager.sharedAuthManager.authorizeFromController(controller)
    }

    /// Handle a redirect and automatically initialize the client and save the token.
    public static func handleRedirectURL(url: NSURL) -> DropboxAuthResult? {
        precondition(DropboxAuthManager.sharedAuthManager != nil, "Call `Dropbox.setupWithAppKey` before calling this method")
        precondition(Dropbox.authorizedClient == nil, "Dropbox user client is already authorized")
        if let result =  DropboxAuthManager.sharedAuthManager.handleRedirectURL(url) {
            switch result {
            case .Success(let token):
                Dropbox.authorizedClient = DropboxClient(accessToken: token)
                return result
            case .Error:
                return result
            }
        } else {
            return nil
        }
    }
    
    /// Handle a redirect and automatically initialize the client and save the token.
    public static func handleRedirectURLTeam(url: NSURL) -> DropboxAuthResult? {
        precondition(DropboxAuthManager.sharedAuthManager != nil, "Call `Dropbox.setupWithTeamAppKey` before calling this method")
        precondition(Dropbox.authorizedTeamClient == nil, "Dropbox team client is already authorized")
        if let result =  DropboxAuthManager.sharedAuthManager.handleRedirectURL(url) {
            switch result {
            case .Success(let token):
                Dropbox.authorizedTeamClient = DropboxTeamClient(accessToken: token)
                return result
            case .Error:
                return result
            }
        } else {
            return nil
        }
    }

    /// Unlink the user.
    public static func unlinkClient() {
        precondition(DropboxAuthManager.sharedAuthManager != nil, "Call `Dropbox.setupWithAppKey` before calling this method")
        if Dropbox.authorizedClient == nil && Dropbox.authorizedTeamClient == nil {
            // already unlinked
            return
        }

        DropboxAuthManager.sharedAuthManager.clearStoredAccessTokens()
        Dropbox.authorizedClient = nil
        Dropbox.authorizedTeamClient = nil
    }
}

