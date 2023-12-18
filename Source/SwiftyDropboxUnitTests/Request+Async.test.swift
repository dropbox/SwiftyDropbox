///
/// Copyright (c) 2023 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

@available(iOS 13.0, macOS 10.15, *)
final class RequestAsyncTests: XCTestCase {
    func testRpcResponseFails() async throws {
        let mockTransferClient = MockDropboxTransportClient()
        mockTransferClient.mockRequestHandler = MockDropboxTransportClient.alwaysFailMockRequestHandler
        let apiClient = DropboxClient(transportClient: mockTransferClient)

        let exp = expectation(description: "should fail")
        do {
            _ = try await apiClient.check.user().response()
            XCTFail("This should fail")
        } catch {
            exp.fulfill()
        }
        await fulfillment(of: [exp])
    }

    func testRpcResponseSucceeds() async throws {
        let mockTransferClient = MockDropboxTransportClient()
        mockTransferClient.mockRequestHandler = { request in
            try? request.handleMockInput(.success(json: [:]))
        }
        let apiClient = DropboxClient(transportClient: mockTransferClient)

        let userCheck = try await apiClient.check.user().response()
        XCTAssertNotNil(userCheck)
    }
}
