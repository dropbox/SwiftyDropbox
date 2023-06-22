///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

extension ScopeRequest {
    var objc: DBXScopeRequest {
        DBXScopeRequest(swift: self)
    }
}

@objc
public class DBXScopeRequest: NSObject {
    let swift: ScopeRequest

    /// Type of the requested scopes.
    @objc public enum DBXScopeType: Int {
        case team
        case user
    }

    /// An array of scopes to be granted.
    @objc
    var scopes: [String] { swift.scopes }
    /// Boolean indicating whether to keep all previously granted scopes.
    @objc
    var includeGrantedScopes: Bool { swift.includeGrantedScopes }
    /// Type of the scopes to be granted.
    @objc
    var scopeType: DBXScopeType {
        switch swift.scopeType {
        case .team:
            return .team
        case .user:
            return .user
        }
    }

    /// String representation of the scopes, used in URL query. Nil if the array is empty.
    @objc
    var scopeString: String? {
        swift.scopeString
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
    @objc
    public init(scopeType: DBXScopeType, scopes: [String], includeGrantedScopes: Bool) {
        let swiftScopeType: ScopeRequest.ScopeType = scopeType == .team ? .team : .user
        self.swift = ScopeRequest(scopeType: swiftScopeType, scopes: scopes, includeGrantedScopes: includeGrantedScopes)
    }

    fileprivate init(swift: ScopeRequest) {
        self.swift = swift
    }
}
