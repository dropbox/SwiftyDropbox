///
/// Copyright (c) 2020 Dropbox, Inc. All rights reserved.
///

import Foundation
import Alamofire

class OAuthTokenExchangeRequest {
    private static let sessionManager: SessionManager = {
        let sessionManager = SessionManager(configuration: .default)
        sessionManager.startRequestsImmediately = false
        return sessionManager
    }()

    private let request: DataRequest
    private var retainSelf: OAuthTokenExchangeRequest?

    init(oauthCode: String, codeVerifier: String, appKey: String, locale: String, redirectUri: String) {
        let headers = [
            "User-Agent": ApiClientConstants.defaultUserAgent,
            "client_id": appKey
        ]
        let params = [
            "grant_type": "authorization_code",
            "code": oauthCode,
            "locale": locale,
            "client_id": appKey,
            "code_verifier": codeVerifier,
            "redirect_uri": redirectUri,
        ]
        request = Self.sessionManager.request(
            "\(ApiClientConstants.apiHost)/oauth2/token",
            method: .post,
            parameters: params,
            headers: headers)
    }

    func start(completion: @escaping DropboxOAuthCompletion) {
        retainSelf = self
        request.validate().responseJSON { [weak self] response in
            let oauthResult: DropboxOAuthResult
            switch response.result {
            case .success(let result):
                if let resultDict = result as? [String: Any],
                    let tokenType = resultDict["token_type"] as? String,
                    tokenType.caseInsensitiveCompare("bearer") == .orderedSame,
                    let accessToken = resultDict["access_token"] as? String,
                    let refreshToken = resultDict["refresh_token"] as? String,
                    let userId = resultDict["uid"] as? String,
                    let expiresIn = resultDict["expires_in"] as? TimeInterval {
                    let expirationTimestamp = Date().addingTimeInterval(expiresIn).timeIntervalSince1970
                    let token = DropboxAccessToken(
                        accessToken: accessToken,
                        uid: userId, refreshToken: refreshToken,
                        tokenExpirationTimestamp: expirationTimestamp
                    )
                    oauthResult = .success(token)
                } else {
                    oauthResult = .error(.unknown, "Invalid response.")
                }
            case .failure:
                oauthResult = .error(.unknown, Self.errorMessageFromResponseData(response.data))
            }
            self?.retainSelf = nil
            completion(oauthResult)
        }
        request.resume()
    }

    func cancel() {
        request.cancel()
        retainSelf = nil
    }

    private static func errorMessageFromResponseData(_ data: Data?) -> String? {
        guard
            let data = data,
            let error = (try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)) as? [String: String],
            let message = error["error_description"]
        else {
            return nil
        }
        return message
    }
}
