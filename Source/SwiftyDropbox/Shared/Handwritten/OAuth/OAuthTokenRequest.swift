///
/// Copyright (c) 2020 Dropbox, Inc. All rights reserved.
///

import Foundation

// MARK: - Authorization Code

typealias NetworkDataTaskCreation = (URLRequest, NetworkTaskTag?, @escaping NetworkDataTaskCompletion) -> NetworkDataTask

/// Request to get an access token with an auth code.
/// See [RFC6749 4.1.3](https://tools.ietf.org/html/rfc6749#section-4.1.3)
class OAuthTokenExchangeRequest: OAuthTokenRequest {
    private let date: Date

    init(
        dataTaskCreation: @escaping NetworkDataTaskCreation,
        oauthCode: String,
        codeVerifier: String,
        appKey: String,
        locale: String,
        redirectUri: String,
        date: Date = Date()
    ) {
        self.date = date
        let params = [
            "grant_type": "authorization_code",
            "code": oauthCode,
            "code_verifier": codeVerifier,
            "redirect_uri": redirectUri,
        ]
        super.init(dataTaskCreation: dataTaskCreation, appKey: appKey, locale: locale, params: params)
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
        let expirationTimestamp = date.addingTimeInterval(expiresIn).timeIntervalSince1970
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
    private let date: Date

    /// Designated Initializer.
    ///
    /// - Parameters:
    ///     - uid: User id.
    ///     - refreshToken: Refresh token.
    ///     - scopes: An array of scopes to be granted for the refreshed access token.
    ///     - appKey: The API app key.
    ///     - locale: User's preferred locale.
    init(
        dataTaskCreation: @escaping NetworkDataTaskCreation,
        uid: String,
        refreshToken: String,
        scopes: [String],
        appKey: String,
        locale: String,
        date: Date = Date()
    ) {
        self.uid = uid
        self.refreshToken = refreshToken
        self.date = date
        var params = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
        ]
        if !scopes.isEmpty {
            params["scope"] = scopes.joined(separator: " ")
        }
        super.init(dataTaskCreation: dataTaskCreation, appKey: appKey, locale: locale, params: params)
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
        let expirationTimestamp = date.addingTimeInterval(expiresIn).timeIntervalSince1970
        return DropboxAccessToken(
            accessToken: accessToken, uid: uid,
            refreshToken: refreshToken, tokenExpirationTimestamp: expirationTimestamp
        )
    }
}

// MARK: - Base Request

/// Makes a network request to `oauth2/token` to get short-lived access token.
class OAuthTokenRequest {
    let request: URLRequest

    private let dataTaskCreation: NetworkDataTaskCreation
    private var task: NetworkDataTask?
    private var retainSelf: OAuthTokenRequest?

    init(dataTaskCreation: @escaping NetworkDataTaskCreation, appKey: String, locale: String, params: RequestParameters) {
        self.dataTaskCreation = dataTaskCreation
        let commonParams = [
            "client_id": appKey,
            "locale": locale,
        ]
        let allParams = params.merging(commonParams) { _, commonParam in commonParam }
        let headers = [
            "User-Agent": ApiClientConstants.defaultUserAgent,
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
        ]

        let url = URL(string: "\(ApiClientConstants.apiHost)/oauth2/token")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = headers

        urlRequest.httpBody = allParams.asUrlEncodedString()?.data(using: .utf8)
        self.request = urlRequest
    }

    /// Start request and set the completion handler.
    /// - Parameters:
    ///     - queue: The queue where completion handler should be called from.
    ///     - completion: The completion block.
    func start(queue: DispatchQueue = DispatchQueue.main, completion: @escaping DropboxOAuthCompletion) {
        retainSelf = self
        var oauthResult: DropboxOAuthResult?

        let task = dataTaskCreation(request, "OAuthTokenRequest") { [weak self] result in
            switch result {
            case .success((let data, _)):
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let token: DropboxAccessToken = try (self?.handleResultDict(json)).orThrow()
                    oauthResult = .success(token)
                } catch {
                    oauthResult = .error(.unknown, "Invalid response.")
                }
            case .failure(let error):
                switch error {
                case .badStatusCode(let data, _, _):
                    oauthResult = Self.resultFromErrorData(data)
                case .failedWithError(let error):
                    oauthResult = .error(.unknown, "Transport error: \(error.localizedDescription)")
                }
            }

            self?.retainSelf = nil
            queue.async { completion(oauthResult) }
        }
        self.task = task
        task.resume()
    }

    func cancel() {
        task?.cancel()
        retainSelf = nil
    }

    fileprivate func handleResultDict(_ result: Any) -> DropboxAccessToken? {
        assertionFailure("Subclasses must implement this method.")
        return nil
    }

    /// Converts error to OAuth2Error as per [RFC6749 5.2](https://tools.ietf.org/html/rfc6749#section-5.2)
    private static func resultFromErrorData(_ data: Data?) -> DropboxOAuthResult {
        guard
            let data = data,
            let error = (try? JSONSerialization.jsonObject(with: data)) as? [String: String],
            let code = error["error"],
            let message = error["error_description"]
        else {
            return .error(.unknown, nil)
        }
        return .error(OAuth2Error(errorCode: code), message)
    }
}
