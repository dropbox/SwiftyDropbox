///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

public enum AuthChallenge {
    public typealias Handler = (URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?)
}
