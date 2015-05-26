//
//  DropboxClient.swift
//  Pods
//
//  Created by Ryan Pearl on 5/20/15.
//
//

import Foundation
import Alamofire

public class DropboxClient : BabelClient {
    
    let accessToken : DropboxAccessToken
    
    public static var sharedClient : DropboxClient!
    
    public init(accessToken: DropboxAccessToken, baseApiUrl: String, baseContentUrl: String, baseNotifyUrl: String) {
        self.accessToken = accessToken
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // Authentication header with access token
        configuration.HTTPAdditionalHeaders = [
            "Authorization" : "Bearer \(self.accessToken)",
        ]
        
        let manager = Manager(configuration: configuration)
        super.init(manager: manager, baseHosts : [
            "meta" : baseApiUrl,
            "content": baseContentUrl,
            "notify": baseNotifyUrl,
            ])
    }
    
    public convenience init(accessToken: DropboxAccessToken) {
        self.init(accessToken: accessToken,
            baseApiUrl: "https://api.dropbox.com/2-beta",
            baseContentUrl: "https://api-content.dropbox.com/2-beta",
            baseNotifyUrl: "https://api-notify.dropbox.com")
    }
}

