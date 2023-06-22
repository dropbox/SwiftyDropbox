///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

extension AccessTokenProvider {
    var objc: DBXAccessTokenProvider {
        DBXAccessTokenProvider(swift: self)
    }
}

@objc
public class DBXAccessTokenProvider: NSObject {
    @objc
    public var accessToken: String { swift.accessToken }

    let swift: AccessTokenProvider

    fileprivate init(swift: AccessTokenProvider) {
        self.swift = swift
    }
}

extension DBXAccessTokenProvider: AccessTokenProvider {
    public func refreshAccessTokenIfNecessary(completion: @escaping DropboxOAuthCompletion) {
        swift.refreshAccessTokenIfNecessary(completion: completion)
    }
}

extension LongLivedAccessTokenProvider {
    var objc: DBXLongLivedAccessTokenProvider {
        DBXLongLivedAccessTokenProvider(swift: self)
    }
}

public class DBXLongLivedAccessTokenProvider: DBXAccessTokenProvider {
    fileprivate init(swift: LongLivedAccessTokenProvider) {
        super.init(swift: swift)
    }

    @objc
    public init(accessToken: String) {
        super.init(swift: LongLivedAccessTokenProvider(accessToken: accessToken))
    }
}

extension ShortLivedAccessTokenProvider {
    var objc: DBXShortLivedAccessTokenProvider {
        DBXShortLivedAccessTokenProvider(swift: self)
    }
}

@objc
public class DBXShortLivedAccessTokenProvider: DBXAccessTokenProvider {
    fileprivate init(swift: ShortLivedAccessTokenProvider) {
        super.init(swift: swift)
    }

    /// - Parameters:
    ///     - token: The `DropboxAccessToken` object for a short-lived token.
    ///     - tokenRefresher: Helper object that refreshes a token over network.
    @objc
    init(token: DBXDropboxAccessToken, tokenRefresher: DBXAccessTokenRefreshing) {
        super.init(swift: ShortLivedAccessTokenProvider(token: token.swift, tokenRefresher: tokenRefresher.swift))
    }
}
