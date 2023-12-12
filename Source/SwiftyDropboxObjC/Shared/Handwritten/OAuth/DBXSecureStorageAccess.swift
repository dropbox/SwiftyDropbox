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

extension SecureStorageAccesDefaultImpl {
    var objc: DBXSecureStorageAccessDefaultImpl {
        DBXSecureStorageAccessDefaultImpl(swift: self)
    }
}

@objc
public class DBXSecureStorageAccessDefaultImpl: NSObject, DBXSecureStorageAccess {
    let swift: SecureStorageAccesDefaultImpl

    fileprivate init(swift: SecureStorageAccesDefaultImpl) {
        self.swift = swift
    }

    @objc
    public override convenience init() {
        self.init(swift: SecureStorageAccesDefaultImpl())
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

@objc
public class DBXSecureStorageAccessTestImpl: NSObject, DBXSecureStorageAccess {
    let swift: SecureStorageAccesTestImpl

    @objc
    public override init() {
        self.swift = SecureStorageAccesTestImpl()
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
