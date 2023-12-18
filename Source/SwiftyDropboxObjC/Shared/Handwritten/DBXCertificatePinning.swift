///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

@objc
public protocol DBXAuthChallengeHandler {
    func handle(challenge: URLAuthenticationChallenge) -> DBXAuthChallengeHandlerResult
}

extension DBXAuthChallengeHandler {
    var swift: AuthChallenge.Handler {
        { [weak self] challenge in
            guard let self = self else {
                return (.cancelAuthenticationChallenge, nil)
            }
            let result = self.handle(challenge: challenge)
            return (result.disposition, result.credential)
        }
    }
}

public class DBXAuthChallengeHandlerResult: NSObject {
    @objc
    public let disposition: URLSession.AuthChallengeDisposition
    @objc
    public let credential: URLCredential?

    @objc
    init(disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?) {
        self.disposition = disposition
        self.credential = credential
    }
}
