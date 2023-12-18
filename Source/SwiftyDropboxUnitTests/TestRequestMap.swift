///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

final class TestRequestMap: XCTestCase {
    var sut: RequestMapImpl!

    override func setUp() {
        sut = RequestMapImpl()
    }

    func testSetAndGet() throws {
        let request1 = MockApiRequest(identifier: 1)
        let request2 = MockApiRequest(identifier: 2)
        sut.set(request: request1, taskIdentifier: 1)
        sut.set(request: request2, taskIdentifier: 2)

        XCTAssertEqual(
            request1.identifier,
            sut.getRequest(taskIdentifier: 1)?.identifier
        )

        XCTAssertEqual(
            request2.identifier,
            sut.getRequest(taskIdentifier: 2)?.identifier
        )
    }

    func testSetAndGetAll() throws {
        let request1 = MockApiRequest(identifier: 1)
        let request2 = MockApiRequest(identifier: 2)
        sut.set(request: request1, taskIdentifier: 1)
        sut.set(request: request2, taskIdentifier: 2)
        XCTAssertEqual(
            [request1, request2].idSet,
            sut.getAllRequests().idSet
        )
    }

    func testRemove() throws {
        let request1 = MockApiRequest(identifier: 1)
        let request2 = MockApiRequest(identifier: 2)
        sut.set(request: request1, taskIdentifier: 1)
        sut.set(request: request2, taskIdentifier: 2)
        sut.removeRequest(taskIdentifier: 1)
        XCTAssertEqual(
            [request2].idSet,
            sut.getAllRequests().idSet
        )
    }

    func testRemoveAll() throws {
        let request1 = MockApiRequest(identifier: 1)
        let request2 = MockApiRequest(identifier: 2)
        sut.set(request: request1, taskIdentifier: 1)
        sut.set(request: request2, taskIdentifier: 2)
        sut.removeAllRequests()
        XCTAssertEqual(
            [].idSet,
            sut.getAllRequests().idSet
        )
    }

    func testWeaklyReferencesRequests() throws {
        sut.set(request: MockApiRequest(identifier: 1), taskIdentifier: 1)
        sut.set(request: MockApiRequest(identifier: 2), taskIdentifier: 2)

        XCTAssertEqual(
            [].idSet,
            sut.getAllRequests().idSet
        )
    }

    func testRetainsPendingReconnections() throws {
        sut.setPendingReconnection(request: MockApiRequest(identifier: 1), taskIdentifier: 1)
        sut.setPendingReconnection(request: MockApiRequest(identifier: 2), taskIdentifier: 2)

        XCTAssertEqual(
            [1, 2],
            sut.getAllRequests().idSet
        )
    }

    func testCanStopRetainingReconnectedRequests() throws {
        sut.setPendingReconnection(request: MockApiRequest(identifier: 1), taskIdentifier: 1)
        sut.setPendingReconnection(request: MockApiRequest(identifier: 2), taskIdentifier: 2)

        XCTAssertEqual(
            [1, 2],
            sut.getAllRequests().idSet
        )

        sut.weakifyReferencesToReconnectedRequests()

        XCTAssertEqual(
            [],
            sut.getAllRequests().idSet
        )
    }

    func testGetAllPendingReconnectionRequests() throws {
        sut.setPendingReconnection(request: MockApiRequest(identifier: 1), taskIdentifier: 1)
        sut.setPendingReconnection(request: MockApiRequest(identifier: 2), taskIdentifier: 2)

        let request = MockApiRequest(identifier: 3)
        sut.set(request: request, taskIdentifier: 3)

        XCTAssertEqual(
            [1, 2],
            sut.getAllPendingReconnectionRequests().idSet
        )
    }

    func testWillCleanupBoxesWithNilRequests() throws {
        sut.__test_only_setCleanupThreshold(value: 3)

        sut.set(request: MockApiRequest(identifier: 1), taskIdentifier: 1)
        sut.set(request: MockApiRequest(identifier: 2), taskIdentifier: 2)

        XCTAssertEqual(sut.__test_only_map.count, 2)

        sut.set(request: MockApiRequest(identifier: 3), taskIdentifier: 3)

        sut.cleanupEmptyBoxes()

        XCTAssertEqual(sut.__test_only_map.count, 0)
    }

    func testWillNotCleanupBoxesWithNonNilRequests() throws {
        sut.__test_only_setCleanupThreshold(value: 3)

        let request1 = MockApiRequest(identifier: 1)
        let request2 = MockApiRequest(identifier: 2)
        let request3 = MockApiRequest(identifier: 3)
        let request4 = MockApiRequest(identifier: 4)

        sut.set(request: request1, taskIdentifier: 1)
        sut.set(request: request2, taskIdentifier: 2)
        sut.set(request: request3, taskIdentifier: 3)
        sut.set(request: request4, taskIdentifier: 4)

        sut.cleanupEmptyBoxes()

        XCTAssertEqual(sut.__test_only_map.count, 4)
    }
}

extension Array where Element == ApiRequest {
    var idSet: Set<Int> {
        Set(map(\.identifier))
    }
}
