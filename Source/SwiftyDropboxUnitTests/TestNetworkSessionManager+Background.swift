///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

extension TestNetworkSessionManager {
    func testRecievingADelegateCallbackForAnUnregisteredTaskWrapsAndRegistersIt() throws {
        let request = sut.apiRequestData(request: { .example() }, networkTaskTag: "delegate-task")
        let mockRequest = try XCTUnwrap(request as? MockApiRequest)
        wait(for: taskCreationExpectations, timeout: 1)

        let underlyingTask = try XCTUnwrap(mockNetworkSession.tasks["delegate-task"] as? NetworkDataTask)

        sut.networkSession(mockNetworkSession, dataTask: underlyingTask, didReceive: Data())

        XCTAssertEqual(sut.requestMap.getAllRequests().count, 1)
        XCTAssertEqual(sut.requestMap.getAllRequests().first?.identifier, mockRequest.identifier)
    }

    func testMultipleDelegateCallbacksDoNotLeadToMultipleRegistrations() throws {
        let request = sut.apiRequestData(request: { .example() }, networkTaskTag: "delegate-task")
        let mockRequest = try XCTUnwrap(request as? MockApiRequest)
        wait(for: taskCreationExpectations, timeout: 1)

        let underlyingTask = try XCTUnwrap(mockNetworkSession.tasks["delegate-task"] as? NetworkDataTask)

        // First
        sut.networkSession(mockNetworkSession, dataTask: underlyingTask, didReceive: Data())

        // Second
        sut.networkSession(mockNetworkSession, task: underlyingTask, didCompleteWithError: nil)

        XCTAssertEqual(createdRequestCount, 1)
        XCTAssertEqual(sut.requestMap.getAllRequests().count, 1)
        XCTAssertEqual(sut.requestMap.getAllRequests().first?.identifier, mockRequest.identifier)
    }

    func testGetAllTasksRewrapsOnlyNewTasksAndReturnsAllUnownedApiRequests() throws {
        let e = expectation(description: "completion called")

        // Set a network session id so that the manager knows it's a background session
        // In background sessions we treat incoming unknown URLSessionDelegate calls differently
        mockNetworkSession.identifier = "bg"

        let existingApiRequest = sut.apiRequestData(request: { .example() }, networkTaskTag: "delegate-task")
        (existingApiRequest as? MockApiRequest)?.identifier = 0
        wait(for: taskCreationExpectations, timeout: 1)

        XCTAssertEqual(createdRequestCount, 1)

        // Add a pending task via URLSessionDelegate
        let pendingViaDelegateTask = MockNetworkTaskDelegate(request: .example())
        pendingViaDelegateTask.taskIdentifier = 1
        sut.networkSession(sut.session, task: pendingViaDelegateTask, didSendBodyData: 0, totalBytesSent: 0, totalBytesExpectedToSend: 0)

        // add a pending task to be vended from URLSession.getAllTasks
        let pendingViaCompletionTask = MockNetworkTaskDelegate(request: .example())
        pendingViaCompletionTask.taskIdentifier = 2

        mockNetworkSession.tasksPendingReconnection = [pendingViaCompletionTask]

        sut.getAllTasks { requests in
            XCTAssertEqual(requests.count, 2)
            XCTAssertEqual(self.createdRequestCount, 3)
            XCTAssertEqual(requests.idSet, [1, 2])
            e.fulfill()
        }

        wait(for: [e], timeout: 1)
    }
}
