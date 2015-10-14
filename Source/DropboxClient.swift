//
//  DropboxClient.swift
//  Pods
//
//  Created by Ryan Pearl on 5/20/15.
//
//

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


public class DropboxClient : BabelClient {
    
    let accessToken : DropboxAccessToken
    
    public static var sharedClient : DropboxClient!
    
    public init(accessToken: DropboxAccessToken, baseApiUrl: String, baseContentUrl: String, baseNotifyUrl: String) {
        self.accessToken = accessToken
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // Authentication header with access token
        configuration.HTTPAdditionalHeaders = [
            "Authorization" : "Bearer \(self.accessToken)",
            "User-Agent": "OfficialDropboxSwiftSDKv2/0.4"
        ]
        
        let manager = Manager(configuration: configuration, serverTrustPolicyManager: DropboxServerTrustPolicyManager())
        super.init(manager: manager, baseHosts : [
            "meta" : baseApiUrl,
            "content": baseContentUrl,
            "notify": baseNotifyUrl,
            ])
    }
    
    public convenience init(accessToken: DropboxAccessToken) {
        self.init(accessToken: accessToken,
            baseApiUrl: "https://api.dropbox.com/2",
            baseContentUrl: "https://api-content.dropbox.com/2",
            baseNotifyUrl: "https://api-notify.dropbox.com")
    }
}
public class Dropbox {
    public static var authorizedClient : DropboxClient?

    public static func setupWithAppKey(appKey : String) {
        precondition(DropboxAuthManager.sharedAuthManager == nil, "Only call `Dropbox.initAppWithKey` once")
        DropboxAuthManager.sharedAuthManager = DropboxAuthManager(appKey: appKey)

        if let token = DropboxAuthManager.sharedAuthManager.getFirstAccessToken() {
            Dropbox.authorizedClient = DropboxClient(accessToken: token)
            DropboxClient.sharedClient = Dropbox.authorizedClient
        }
    }

    public static func authorizeFromController(controller: UIViewController) {
        precondition(DropboxAuthManager.sharedAuthManager != nil, "Call `Dropbox.initAppWithKey` before calling this method")
        precondition(Dropbox.authorizedClient == nil, "Client is already authorized")
        DropboxAuthManager.sharedAuthManager.authorizeFromController(controller)
    }

    public static func handleRedirectURL(url: NSURL) -> DropboxAuthResult? {
        precondition(DropboxAuthManager.sharedAuthManager != nil, "Call `Dropbox.initAppWithKey` before calling this method")
        precondition(Dropbox.authorizedClient == nil, "Client is already authorized")
        if let result =  DropboxAuthManager.sharedAuthManager.handleRedirectURL(url) {
            switch result {
            case .Success(let token):
                Dropbox.authorizedClient = DropboxClient(accessToken: token)
                DropboxClient.sharedClient = Dropbox.authorizedClient
                return result
            case .Error:
                return result
            }
        } else {
            return nil
        }
    }

    public static func unlinkClient() {
        precondition(DropboxAuthManager.sharedAuthManager != nil, "Call `Dropbox.initAppWithKey` before calling this method")
        if Dropbox.authorizedClient == nil {
            // already unlinked
            return
        }

        DropboxAuthManager.sharedAuthManager.clearStoredAccessTokens()
        Dropbox.authorizedClient = nil
        DropboxClient.sharedClient = nil
    }
}

