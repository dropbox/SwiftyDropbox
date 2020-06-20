///
/// Copyright (c) 2020 Dropbox, Inc. All rights reserved.
///

import Foundation

/// Contains utility methods used in auth flow. e.g. method to construct URL query.
enum OAuthUtils {
    static func createPkceCodeFlowParams(for authSession: OAuthPKCESession) -> [URLQueryItem] {
        var params = [URLQueryItem]()
        if let scopeString = authSession.scopeRequest?.scopeString {
            params.append(URLQueryItem(name: OAuthConstants.scopeKey, value: scopeString))
        }
        if let scopeRequest = authSession.scopeRequest, scopeRequest.includeGrantedScopes {
            params.append(
                URLQueryItem(name: OAuthConstants.includeGrantedScopesKey, value: scopeRequest.scopeType.rawValue)
            )
        }
        let pkceData = authSession.pkceData
        params.append(contentsOf: [
            URLQueryItem(name: OAuthConstants.codeChallengeKey, value: pkceData.codeChallenge),
            URLQueryItem(name: OAuthConstants.codeChallengeMethodKey, value: pkceData.codeChallengeMethod),
            URLQueryItem(name: OAuthConstants.tokenAccessTypeKey, value: authSession.tokenAccessType),
            URLQueryItem(name: OAuthConstants.responseTypeKey, value: authSession.responseType),
            URLQueryItem(name: OAuthConstants.stateKey, value: authSession.state),
        ])
        return params
    }

    // Extracts query parameters from URL and removes percent encoding.
    static func extractParamsFromUrl(_ url: URL) -> [String: String] {
        if let urlComponents = URLComponents(string: url.absoluteString),
            let queryItems = urlComponents.queryItems {
				return queryItems.reduce(into: [String: String]()) { result, queryItem in
					 result[queryItem.name] = queryItem.value
				}
        }
		
		if let frags = url.fragment?.components(separatedBy: "&") {
			return frags.reduce(into: [String: String]()) { result, queryItem in
				let split = queryItem.components(separatedBy: "=")
				if split.count == 2 { result[split[0]] = split[1] }
			}
		}
		
		return [:]
    }
}
