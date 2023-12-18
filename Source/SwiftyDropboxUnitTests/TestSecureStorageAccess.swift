///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

final class TestSecureStorageAccess: XCTestCase {
    private var appBundlePath: String!
    private var extensionBundlePath: String!

    override func setUpWithError() throws {
        appBundlePath = "private/var/containers/Bundle/Application/some-uuid/TestSwiftyDropbox_iOS.app"

        extensionBundlePath = "private/var/containers/Bundle/Application/some-uuid/TestSwiftyDropbox_iOS.app/PlugIns/TestSwiftyDropbox_ActionExtension.appex"
    }

    func testCanFindAppBundleFromExtension() {
        let bundlePath = SecureStorageAccessDefaultImpl.appBundlePath(from: extensionBundlePath)
        XCTAssertEqual(bundlePath, appBundlePath)
    }

    func testCanFindAppBundleFromApp() {
        let bundlePath = SecureStorageAccessDefaultImpl.appBundlePath(from: appBundlePath)
        XCTAssertEqual(bundlePath, appBundlePath)
    }
}
