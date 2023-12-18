//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation
import SwiftyDropbox

@objc
public protocol DBXSecureStorageAccess {
    func checkAccessibilityMigrationOneTime()
    func setAccessTokenData(for userId: String, data: Data) -> Bool
    func getAllUserIds() -> [String]
    func getDropboxAccessToken(for key: String) -> DBXDropboxAccessToken?
    func deleteInfo(for key: String) -> Bool
    func deleteInfoForAllKeys() -> Bool
}

extension SecureStorageAccessDefaultImpl {
    var objc: DBXSecureStorageAccessDefaultImpl {
        DBXSecureStorageAccessDefaultImpl(swift: self)
    }
}

@objc
open class DBXSecureStorageAccessImpl: NSObject, DBXSecureStorageAccess {
    let swift: SecureStorageAccess

    public init(swift: SecureStorageAccess) {
        self.swift = swift
    }

    public func checkAccessibilityMigrationOneTime() {
        swift.checkAccessibilityMigrationOneTime()
    }

    public func setAccessTokenData(for userId: String, data: Data) -> Bool {
        swift.setAccessTokenData(for: userId, data: data)
    }

    public func getAllUserIds() -> [String] {
        swift.getAllUserIds()
    }

    public func getDropboxAccessToken(for key: String) -> DBXDropboxAccessToken? {
        swift.getDropboxAccessToken(for: key)?.objc
    }

    public func deleteInfo(for key: String) -> Bool {
        swift.deleteInfo(for: key)
    }

    public func deleteInfoForAllKeys() -> Bool {
        swift.deleteInfoForAllKeys()
    }
}

@objc
public class DBXSecureStorageAccessDefaultImpl: DBXSecureStorageAccessImpl {
    @objc
    public convenience init() {
        self.init(swift: SecureStorageAccessDefaultImpl())
    }

    fileprivate init(swift: SecureStorageAccessDefaultImpl) {
        super.init(swift: swift)
    }
}

extension DBXSecureStorageAccess {
    var swift: SecureStorageAccess {
        SecureStorageAccessBridge(objc: self)
    }
}

public class SecureStorageAccessBridge: NSObject, SecureStorageAccess {
    let objc: DBXSecureStorageAccess

    init(objc: DBXSecureStorageAccess) {
        self.objc = objc
    }

    public func checkAccessibilityMigrationOneTime() {
        objc.checkAccessibilityMigrationOneTime()
    }

    public func setAccessTokenData(for userId: String, data: Data) -> Bool {
        objc.setAccessTokenData(for: userId, data: data)
    }

    public func getAllUserIds() -> [String] {
        objc.getAllUserIds()
    }

    public func getDropboxAccessToken(for key: String) -> DropboxAccessToken? {
        objc.getDropboxAccessToken(for: key)?.swift
    }

    public func deleteInfo(for key: String) -> Bool {
        objc.deleteInfo(for: key)
    }

    public func deleteInfoForAllKeys() -> Bool {
        objc.deleteInfoForAllKeys()
    }
}
