///
/// Copyright (c) 2020 Dropbox, Inc. All rights reserved.
///

import Foundation
import CommonCrypto

// MARK: Public

/// Struct contains the information of a requested scopes.
public struct ScopeRequest {
    /// Type of the requested scopes.
    public enum ScopeType: String {
        case team
        case user
    }

    /// An array of scopes to be granted.
    let scopes: [String]
    /// Boolean indicating whether to keep all previously granted scopes.
    let includeGrantedScopes: Bool
    /// Type of the scopes to be granted.
    let scopeType: ScopeType

    /// String representation of the scopes, used in URL query. Nil if the array is empty.
    var scopeString: String? {
        guard !scopes.isEmpty else { return nil }
        return scopes.joined(separator: " ")
    }

    /// Designated Initializer.
    ///
    /// - Parameters:
    ///     - scopeType: Type of the requested scopes.
    ///     - scopes: A list of scope returned by Dropbox server. Each scope correspond to a group of API endpoints.
    ///       To call one API endpoint you have to obtains the scope first otherwise you will get HTTP 401.
    ///     - includeGrantedScopes: If false, Dropbox will give you the scopes in scopes array.
    ///       Otherwise Dropbox server will return a token with all scopes user previously granted your app
    ///       together with the new scopes.
    public init(scopeType: ScopeType, scopes: [String], includeGrantedScopes: Bool) {
        self.scopeType = scopeType
        self.scopes = scopes
        self.includeGrantedScopes = includeGrantedScopes
    }
}

// MARK: Internal

/// Object that contains all the necessary data of an OAuth 2 Authorization Code Flow with PKCE.s
struct OAuthPKCESession {
    // The scope request for this auth session.
    let scopeRequest: ScopeRequest?
    // PKCE data generated for this auth session.
    let pkceData: PkceData
    // A string of colon-delimited options/state - used primarily to indicate if the token type to be returned.
    let state: String
    // Token access type, hardcoded to "offline" to indicate short-lived access token + refresh token.
    let tokenAccessType = "offline"
    // Type of the auth response, hardcoded to "code" to indicate code flow.
    let responseType = "code"

    init(scopeRequest: ScopeRequest?) {
        self.pkceData = PkceData()
        self.scopeRequest = scopeRequest
        self.state = Self.createState(with: pkceData, scopeRequest: scopeRequest, tokenAccessType: tokenAccessType)
    }

    private static func createState(
        with pkceData: PkceData, scopeRequest: ScopeRequest?, tokenAccessType: String
    ) -> String {
        var state = ["oauth2code", pkceData.codeChallenge, pkceData.codeChallengeMethod, tokenAccessType]
        if let scopeRequest = scopeRequest {
            if let scopeString = scopeRequest.scopeString {
                state.append(scopeString)
            }
            if scopeRequest.includeGrantedScopes {
                state.append(scopeRequest.scopeType.rawValue)
            }
        }
        return state.joined(separator: ":")
    }
}

/// PKCE data for OAuth 2 Authorization Code Flow.
struct PkceData {
    // A random string generated for each code flow.
    let codeVerifier = Self.randomStringOfLength(128)
    // A string derived from codeVerifier by using BASE64URL-ENCODE(SHA256(ASCII(code_verifier))).
    let codeChallenge: String
    // The hash method used to generate codeChallenge.
    let codeChallengeMethod = "S256"

    init() {
        self.codeChallenge = Self.codeChallengeFromCodeVerifier(codeVerifier)
    }

    private static func randomStringOfLength(_ length: Int) -> String {
        let alphanumerics = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in alphanumerics.randomElement()! })
    }

    private static func codeChallengeFromCodeVerifier(_ codeVerifier: String) -> String {
        guard let data = codeVerifier.data(using: .ascii) else { fatalError("Failed to create code challenge.") }
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0.baseAddress, UInt32(data.count), &digest)
        }
        /// Replace these characters to make the string safe to use in a URL.
        return Data(digest).base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }
}
