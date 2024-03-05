//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

public protocol SecureStorageAccess {
    func checkAccessibilityMigrationOneTime()
    func setAccessTokenData(for userId: String, data: Data) -> Bool
    func getAllUserIds() -> [String]
    func getDropboxAccessToken(for key: String) -> DropboxAccessToken?
    func deleteInfo(for key: String) -> Bool
    func deleteInfoForAllKeys() -> Bool
}

public class SecureStorageAccessDefaultImpl: SecureStorageAccess {
    private let _checkAccessibilityMigrationOneTime: () = {
        checkAccessibilityMigration()
    }()

    public init() {}

    public func checkAccessibilityMigrationOneTime() {
        _checkAccessibilityMigrationOneTime
    }

    public func setAccessTokenData(for userId: String, data: Data) -> Bool {
        let query = queryWithDict([
            kSecAttrAccount as String: userId as AnyObject,
            kSecValueData as String: data as AnyObject,
        ])

        SecItemDelete(query)

        return SecItemAdd(query, nil) == noErr
    }

    public func getAllUserIds() -> [String] {
        let query = queryWithDict([
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitAll,
        ])

        var dataResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataResult)

        if status == noErr {
            let results = dataResult as? [[String: AnyObject]] ?? []
            return results.map { d in d["acct"] as! String }
        }
        return []
    }

    public func getDropboxAccessToken(for key: String) -> DropboxAccessToken? {
        if let data = getData(for: key) {
            do {
                let jsonDecoder = JSONDecoder()
                return try jsonDecoder.decode(DropboxAccessToken.self, from: data)
            } catch {
                // The token might be stored as a string by a previous version of SDK.
                if let accessTokenString = String(data: data, encoding: .utf8) {
                    return DropboxAccessToken(accessToken: accessTokenString, uid: key)
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
    }

    public func deleteInfo(for key: String) -> Bool {
        let query = queryWithDict([
            kSecAttrAccount as String: key as AnyObject,
        ])

        return SecItemDelete(query) == noErr
    }

    public func deleteInfoForAllKeys() -> Bool {
        let query = queryWithDict([:])
        return SecItemDelete(query) == noErr
    }

    private static func checkAccessibilityMigration() {
        let kAccessibilityMigrationOccurredKey = "KeychainAccessibilityMigration"
        let MigrationOccurred = UserDefaults.standard.string(forKey: kAccessibilityMigrationOccurredKey)

        if MigrationOccurred != "true" {
            let queryDict = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "\(appBundleId()).dropbox.authv2" as AnyObject?,
            ]
            let attributesToUpdateDict = [kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly]
            SecItemUpdate(queryDict as CFDictionary, attributesToUpdateDict as CFDictionary)
            UserDefaults.standard.set("true", forKey: kAccessibilityMigrationOccurredKey)
        }
    }

    private func getData(for key: String) -> Data? {
        let query = queryWithDict([
            kSecAttrAccount as String: key as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ])

        var dataResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataResult)

        if status == noErr {
            return dataResult as? Data
        }

        return nil
    }

    private func queryWithDict(_ query: [String: AnyObject]) -> CFDictionary {
        var queryDict = query

        queryDict[kSecClass as String] = kSecClassGenericPassword
        queryDict[kSecAttrService as String] = "\(Self.appBundleId()).dropbox.authv2" as AnyObject?
        queryDict[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        return queryDict as CFDictionary
    }

    static func appBundleId() -> String {
        let bundlePath = appBundleAbsolutePath(from: Bundle.main.bundleURL.path)
        let bundle = Bundle(path: bundlePath)
        guard let bundleId = bundle?.bundleIdentifier else {
            fatalError("Unable to create bundle")
        }
        return bundleId
    }

    /// kSecAttrService cannot differ between binaries using keychain sharing.
    /// This finds the true owning bundle in the event that we're running in an app extension.
    static func appBundleAbsolutePath(from bundlePath: String) -> String {
        var components = bundlePath.split(separator: "/")

        if let index = components.lastIndex(where: { $0.hasSuffix(".app") }) {
            let componentCountAfterDotApp = (components.count - 1) - index
            components.removeLast(componentCountAfterDotApp)
            return "/" + components.joined(separator: "/")
        } else {
            fatalError("Unable to find app bundle path")
        }
    }
}
