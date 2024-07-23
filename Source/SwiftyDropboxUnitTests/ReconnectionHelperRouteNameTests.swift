///
/// Copyright (c) 2024 Dropbox, Inc. All rights reserved.
///

import Foundation

@testable import SwiftyDropbox
import XCTest

final class TestReconnectionHelperRouteNameMatching: XCTestCase {
    func testMatching() throws {
        let route = Files.uploadSessionAppendV2
        let persistedInfo = ReconnectionHelpers.PersistedRequestInfo.upload(
            .init(
                originalSDKVersion: DropboxClientsManager.sdkVersion,
                routeName: route.name,
                routeNamespace: route.namespace,
                clientProvidedInfo: nil
            )
        )

        let request = MockApiRequest(identifier: 0)
        request.taskDescription = try persistedInfo.asJsonString()

        let rebuiltRequest = try ReconnectionHelpers.rebuildRequest(apiRequest: request, client: MockDropboxTransportClient())

        // Assert that request was successfully rebuilt
        XCTAssertEqual(rebuiltRequest.description, "uploadSessionAppendV2")
    }
}
