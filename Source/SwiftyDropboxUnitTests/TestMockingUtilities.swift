///
/// Copyright (c) 2023 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

final class TestMockingUtilities: XCTestCase {
    func testExampleModel() throws {
        let e = expectation(description: "webservice closure called")

        let (filesRoutes, mockTransportClient) = MockingUtilities.makeMock(forType: FilesRoutes.self)
        let webService = ExampleWebService(routes: filesRoutes)

        webService.getMetadata { result, _ in
            XCTAssertNotNil(result)
            e.fulfill()
        }

        let model: Files.Metadata = Files.FileMetadata(
            name: "name", id: "id", clientModified: Date(), serverModified: Date(), rev: "123456789", size: 0
        )
        try mockTransportClient.getLastRequest()?.handleMockInput(
            .success(model: model)
        )

        wait(for: [e], timeout: 1)
    }

    func testExampleJsonFixture() throws {
        let e = expectation(description: "webservice closure called")

        let (filesRoutes, mockTransportClient) = MockingUtilities.makeMock(forType: FilesRoutes.self)
        let webService = ExampleWebService(routes: filesRoutes)

        webService.getMetadata { result, _ in
            XCTAssertNotNil(result)
            e.fulfill()
        }

        let fileMetadataJSON: [String: Any] =
            [
                ".tag": "file",
                "id": "id",
                "server_modified": "2023-12-15T13:43:32Z",
                "name": "name",
                "size": 0,
                "client_modified": "2023-12-15T13:43:32Z",
                "rev": "123456789",
                "is_downloadable": 1,
            ]
        try mockTransportClient.getLastRequest()?.handleMockInput(
            .success(json: fileMetadataJSON)
        )

        wait(for: [e], timeout: 1)
    }

    func testExampleError() throws {
        let e = expectation(description: "webservice closure called")

        let (filesRoutes, mockTransportClient) = MockingUtilities.makeMock(forType: FilesRoutes.self)
        let webService = ExampleWebService(routes: filesRoutes)
        let expectedError = Files.GetMetadataError.path(.notFound)

        webService.getMetadata { _, error in
            let error = try! XCTUnwrap(error)
            if case .routeError = error {
                // successfully produced a Files.GetMetadataError
            } else {
                XCTFail()
            }
            e.fulfill()
        }

        try mockTransportClient.getLastRequest()?.handleMockInput(
            .routeError(model: expectedError)
        )

        wait(for: [e], timeout: 1)
    }

    func testExampleErrorJSON() throws {
        let e = expectation(description: "webservice closure called")

        let (filesRoutes, mockTransportClient) = MockingUtilities.makeMock(forType: FilesRoutes.self)
        let webService = ExampleWebService(routes: filesRoutes)

        let expectedErrorJSON: [String: Any] = [
            "path": [".tag": "not_found"],
            ".tag": "path",
        ]

        webService.getMetadata { _, error in
            let error = try! XCTUnwrap(error)
            if case .routeError = error {
                // successfully produced a Files.GetMetadataError
            } else {
                XCTFail()
            }
            e.fulfill()
        }

        try mockTransportClient.getLastRequest()?.handleMockInput(
            .routeError(json: [
                "error": expectedErrorJSON,
                "error_summary": "error_summary",
            ])
        )

        wait(for: [e], timeout: 1)
    }
}

private class ExampleWebService {
    var routes: FilesRoutes

    init(routes: FilesRoutes) {
        self.routes = routes
    }

    func getMetadata(completion: @escaping (Files.Metadata?, CallError<Files.GetMetadataError>?) -> Void) {
        routes.getMetadata(path: "/real/path").response { result, error in
            completion(result, error)
        }
    }
}
