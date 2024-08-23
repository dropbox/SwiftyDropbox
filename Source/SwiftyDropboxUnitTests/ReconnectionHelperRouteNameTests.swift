///
/// Copyright (c) 2024 Dropbox, Inc. All rights reserved.
///

import Foundation

@testable import SwiftyDropbox
import XCTest

final class TestReconnectionHelperRouteNameMatching: XCTestCase {
    private let destination = URL(string: "/some/file.jpg")!

    func testMatchingFilesUploadSessionAppendV2() throws {
        try executeMatchingTest(route: Files.uploadSessionAppendV2, expectedRebuiltDescription: "files/upload_session/append_v2", upload: true)
    }

    func testMatchingFilesDownloadZip() throws {
        try executeMatchingTest(route: Files.downloadZip, expectedRebuiltDescription: "files/download_zip", upload: false)
    }

    func testMatchingSharingGetSharedLinkFile() throws {
        try executeMatchingTest(route: Sharing.getSharedLinkFile, expectedRebuiltDescription: "sharing/get_shared_link_file", upload: false)
    }

    func testMatchingPaperDocsDownload() throws {
        try executeMatchingTest(route: Paper.docsDownload, expectedRebuiltDescription: "paper/docs/download", upload: false)
    }

    private func executeMatchingTest<A, R, E>(route: Route<A, R, E>, expectedRebuiltDescription: String, upload: Bool) throws {
        let persistedInfo: ReconnectionHelpers.PersistedRequestInfo = upload
            ? .upload(
                .init(
                    originalSDKVersion: DropboxClientsManager.sdkVersion,
                    routeName: route.name,
                    routeNamespace: route.namespace,
                    clientProvidedInfo: nil
                )
            )
            : .downloadFile(
                .init(
                    originalSDKVersion: DropboxClientsManager.sdkVersion,
                    routeName: route.name,
                    routeNamespace: route.namespace,
                    destination: destination,
                    overwrite: true
                )
            )

        let request = MockApiRequest(identifier: 0)
        request.taskDescription = try persistedInfo.asJsonString()

        let rebuiltRequest = try ReconnectionHelpers.rebuildRequest(apiRequest: request, client: MockDropboxTransportClient())

        // Assert that request was successfully rebuilt
        XCTAssertEqual(rebuiltRequest.description, expectedRebuiltDescription)
    }
}
