///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

@testable import SwiftyDropbox
import XCTest

final class TestReconnectionHelperPersistedRequestInfo: XCTestCase {
    let routeName = "deleteV2"
    let routeNamespace = "files"
    let clientProvidedInfo = "example"

    let destination = URL(string: "/some/file.jpg")!
    let overwrite = true

    lazy var uploadInfo: ReconnectionHelpers.PersistedRequestInfo = .upload(
        ReconnectionHelpers.PersistedRequestInfo.StandardInfo(
            originalSDKVersion: DropboxClientsManager.sdkVersion,
            routeName: routeName,
            routeNamespace: routeNamespace,
            clientProvidedInfo: clientProvidedInfo
        )
    )

    lazy var downloadFileInfo: ReconnectionHelpers.PersistedRequestInfo = .downloadFile(
        ReconnectionHelpers.PersistedRequestInfo.DownloadFileInfo(
            originalSDKVersion: DropboxClientsManager.sdkVersion,
            routeName: routeName,
            routeNamespace: routeNamespace,
            clientProvidedInfo: clientProvidedInfo,
            destination: destination,
            overwrite: overwrite
        )
    )

    func testCodingRoundtrip() throws {
        XCTAssertEqual(
            uploadInfo,
            try ReconnectionHelpers.PersistedRequestInfo.from(jsonString: try uploadInfo.asJsonString())
        )
    }

    func testDownloadFileCodingRoundtrip() throws {
        XCTAssertEqual(
            downloadFileInfo,
            try ReconnectionHelpers.PersistedRequestInfo.from(jsonString: try downloadFileInfo.asJsonString())
        )
    }
}
