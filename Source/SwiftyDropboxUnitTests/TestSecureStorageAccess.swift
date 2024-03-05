///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

final class TestSecureStorageAccess: XCTestCase {
    private var appBundlePath: String!
    private var extensionBundlePath: String!
    private var macAppBundlePath: String!

    override func setUpWithError() throws {
        appBundlePath = "/private/var/containers/Bundle/Application/some-uuid/TestSwiftyDropbox_iOS.app"
        extensionBundlePath = "/private/var/containers/Bundle/Application/some-uuid/TestSwiftyDropbox_iOS.app/PlugIns/TestSwiftyDropbox_ActionExtension.appex"
        macAppBundlePath = "/Users/name/Library/Developer/Xcode/DerivedData/TestSwiftyDropbox-uuid/Build/Products/Debug/TestSwiftyDropbox_macOS.app"
    }

    func testCanFindAppBundleFromExtension() {
        let bundlePath = SecureStorageAccessDefaultImpl.appBundleAbsolutePath(from: extensionBundlePath)
        XCTAssertEqual(bundlePath, appBundlePath)
    }

    func testCanFindAppBundleFromApp() {
        let bundlePath = SecureStorageAccessDefaultImpl.appBundleAbsolutePath(from: appBundlePath)
        XCTAssertEqual(bundlePath, appBundlePath)
    }

    func testPathIsAbsolute() {
        let bundlePath = SecureStorageAccessDefaultImpl.appBundleAbsolutePath(from: macAppBundlePath)
        XCTAssertEqual(bundlePath.first, "/")
    }
}
