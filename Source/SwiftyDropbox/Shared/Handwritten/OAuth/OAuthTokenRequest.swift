///
/// Copyright (c) 2020 Dropbox, Inc. All rights reserved.
///

import Foundation
import Alamofire

// MARK: - Authorization Code

/// Request to get an access token with an auth code.
/// See [RFC6749 4.1.3](https://tools.ietf.org/html/rfc6749#section-4.1.3)
class OAuthTokenExchangeRequest: OAuthTokenRequest {
    init(oauthCode: String, codeVerifier: String, appKey: String, locale: String, redirectUri: String) {
        let params = [
            "grant_type": "authorization_code",
            "code": oauthCode,
            "code_verifier": codeVerifier,
            "redirect_uri": redirectUri,
        ]
        super.init(appKey: appKey, locale: locale, params: params)
    }

    /// Handle access token result as per [RFC6749 4.1.4](https://tools.ietf.org/html/rfc6749#section-4.1.4)
    /// And an additional DBX uid parameter.
    override func handleResultDict(_ result: Any) -> DropboxAccessToken? {
        guard let resultDict = result as? [String: Any],
            let tokenType = resultDict["token_type"] as? String,
            tokenType.caseInsensitiveCompare("bearer") == .orderedSame,
            let accessToken = resultDict["access_token"] as? String,
            let refreshToken = resultDict["refresh_token"] as? String,
            let userId = resultDict["uid"] as? String,
            let expiresIn = resultDict["expires_in"] as? TimeInterval else {
            return nil
        }
        let expirationTimestamp = Date().addingTimeInterval(expiresIn).timeIntervalSince1970
        return DropboxAccessToken(
            accessToken: accessToken, uid: userId,
            refreshToken: refreshToken, tokenExpirationTimestamp: expirationTimestamp
        )
    }
}

// MARK: - Refresh Token

/// Request to refresh an access token. See [RFC6749 6](https://tools.ietf.org/html/rfc6749#section-6)
class OAuthTokenRefreshRequest: OAuthTokenRequest {
    private let uid: String
    private let refreshToken: String

    /// Designated Initializer.
    /// 
    /// - Parameters:
    ///     - uid: User id.
    ///     - refreshToken: Refresh token.
    ///     - scopes: An array of scopes to be granted for the refreshed access token.
    ///     - appKey: The API app key.
    ///     - locale: User's preferred locale.
    init(uid: String, refreshToken: String, scopes: [String], appKey: String, locale: String) {
        self.uid = uid
        self.refreshToken = refreshToken
        var params = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
        ]
        if !scopes.isEmpty {
            params["scope"] = scopes.joined(separator: " ")
        }
        super.init(appKey: appKey, locale: locale, params: params)
    }

    /// Handle refresh result as per [RFC6749 5.1](https://tools.ietf.org/html/rfc6749#section-5.1)
    override func handleResultDict(_ result: Any) -> DropboxAccessToken? {
        guard let resultDict = result as? [String: Any],
            let tokenType = resultDict["token_type"] as? String,
            tokenType.caseInsensitiveCompare("bearer") == .orderedSame,
            let accessToken = resultDict["access_token"] as? String,
            let expiresIn = resultDict["expires_in"] as? TimeInterval else {
            return nil
        }
        let expirationTimestamp = Date().addingTimeInterval(expiresIn).timeIntervalSince1970
        return DropboxAccessToken(
            accessToken: accessToken, uid: uid,
            refreshToken: refreshToken, tokenExpirationTimestamp: expirationTimestamp
        )
    }
}

// MARK: - Base Request

/// Makes a network request to `oauth2/token` to get short-lived access token.
class OAuthTokenRequest {
    private static let sessionManager: SessionManager = {
        let sessionManager = SessionManager(configuration: .default)
        sessionManager.startRequestsImmediately = false
        return sessionManager
    }()

    private let request: DataRequest
    private var retainSelf: OAuthTokenRequest?

    init(appKey: String, locale: String, params: Parameters) {
        let commonParams = [
            "client_id": appKey,
            "locale": locale,
        ]
        let allParams = params.merging(commonParams) { (_, commonParam) in commonParam }
        let headers = ["User-Agent": ApiClientConstants.defaultUserAgent]
        request = Self.sessionManager.request(
            "\(ApiClientConstants.apiHost)/oauth2/token",
            method: .post,
            parameters: allParams,
            headers: headers)
    }

    /// Start request and set the completion handler.
    /// - Parameters:
    ///     - queue: The queue where completion handler should be called from.
    ///     - completion: The completion block.
    func start(queue: DispatchQueue = DispatchQueue.main, completion: @escaping DropboxOAuthCompletion) {
        retainSelf = self
        request.validate().responseJSON { [weak self] response in
            let oauthResult: DropboxOAuthResult
            switch response.result {
            case .success(let result):
                if let token = self?.handleResultDict(result) {
                    oauthResult = .success(token)
                } else {
                    oauthResult = .error(.unknown, "Invalid response.")
                }
            case .failure:
                oauthResult = Self.resultFromErrorData(response.data)
            }
            self?.retainSelf = nil
            queue.async { completion(oauthResult) }
        }
        request.resume()
    }

    func cancel() {
        request.cancel()
        retainSelf = nil
    }

    fileprivate func handleResultDict(_ result: Any) -> DropboxAccessToken? {
        assert(false, "Subclasses must implement this method.")
        return nil
    }

    /// Converts error to OAuth2Error as per [RFC6749 5.2](https://tools.ietf.org/html/rfc6749#section-5.2)
    private static func resultFromErrorData(_ data: Data?) -> DropboxOAuthResult {
        guard
            let data = data,
            let error = (try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)) as? [String: String],
            let code = error["error"],
            let message = error["error_description"]
        else {
            return .error(.unknown, nil)
        }
        return .error(OAuth2Error(errorCode: code), message)
    }
}
