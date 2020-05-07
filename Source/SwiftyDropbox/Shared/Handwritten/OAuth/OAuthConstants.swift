///
/// Copyright (c) 2020 Dropbox, Inc. All rights reserved.
///

import Foundation

/// Contains the keys of URL queries and responses in auth flow.
enum OAuthConstants {
    static let codeChallengeKey = "code_challenge"
    static let codeChallengeMethodKey = "code_challenge_method"
    static let tokenAccessTypeKey = "token_access_type"
    static let responseTypeKey = "response_type"
    static let scopeKey = "scope"
    static let includeGrantedScopesKey = "include_granted_scopes"
    static let stateKey = "state"
    static let extraQueryParamsKey = "extra_query_params"
}
