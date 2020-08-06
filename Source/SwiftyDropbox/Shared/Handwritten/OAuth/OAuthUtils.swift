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
        ])
        return params
    }


    /// Extracts auth response parameters from URL and removes percent encoding.
    /// Response parameters from DAuth via the Dropbox app are in the query component.
    static func extractDAuthResponseFromUrl(_ url: URL) -> [String: String] {
        extractQueryParamsFromUrlString(url.absoluteString)
    }

    /// Extracts auth response parameters from URL and removes percent encoding.
    /// Response parameters OAuth 2 code flow (RFC6749 4.1.2) are in the query component.
    static func extractOAuthResponseFromCodeFlowUrl(_ url: URL) -> [String: String] {
        extractQueryParamsFromUrlString(url.absoluteString)
    }

    /// Extracts auth response parameters from URL and removes percent encoding.
    /// Response parameters from OAuth 2 token flow (RFC6749 4.2.2) are in the fragment component.
    static func extractOAuthResponseFromTokenFlowUrl(_ url: URL) -> [String: String] {
        guard let urlComponents = URLComponents(string: url.absoluteString),
            let responseString = urlComponents.fragment else {
                return [:]
        }
        // Create a query only URL string and extract its individual query parameters.
        return extractQueryParamsFromUrlString("?\(responseString)")
    }

    /// Extracts query parameters from URL and removes percent encoding.
    private static func extractQueryParamsFromUrlString(_ urlString: String) -> [String: String] {
        guard let urlComponents = URLComponents(string: urlString),
            let queryItems = urlComponents.queryItems else {
            return [:]
        }
        return queryItems.reduce(into: [String: String]()) { result, queryItem in
            result[queryItem.name] = queryItem.value
        }
    }
}
