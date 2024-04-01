//
//  TestSecureStorageAccess.swift
//  TestSwiftyDropbox
//
//  Created by jlocke on 12/13/23.
//  Copyright © 2023 Dropbox. All rights reserved.
//

import Foundation
import SwiftyDropbox
import SwiftyDropboxObjC

public extension DBXDropboxOAuthManager {
    @objc
    static func __test_only_resetForTeamSetup() {
        DropboxOAuthManager.sharedOAuthManager = nil
    }
}

@objc
public class DBXSecureStorageAccessTestImpl: DBXSecureStorageAccessImpl {
    @objc
    public convenience init() {
        self.init(swift: SecureStorageAccessTestImpl())
    }

    fileprivate init(swift: SecureStorageAccessTestImpl) {
        super.init(swift: swift)
    }
}

public class SecureStorageAccessTestImpl: SecureStorageAccess {
    private static var accessTokenData: Data?

    public init() {}

    public func checkAccessibilityMigrationOneTime() {}

    public func setAccessTokenData(for userId: String, data: Data) -> Bool {
        Self.accessTokenData = data
        return true
    }

    public func getAllUserIds() -> [String] {
        [TestAuthTokenGenerator.testUid]
    }

    public func getDropboxAccessToken(for key: String) -> DropboxAccessToken? {
        guard let accessTokenData = Self.accessTokenData else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(DropboxAccessToken.self, from: accessTokenData)
    }

    public func deleteInfo(for key: String) -> Bool {
        true
    }

    public func deleteInfoForAllKeys() -> Bool {
        true
    }
}
