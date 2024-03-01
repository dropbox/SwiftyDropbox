///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

final class TestNetworkSessionManager: XCTestCase {
    var sut: NetworkSessionManager!
    var mockNetworkSession: MockNetworkSession!
    var createdRequestCount: Int = 0
    var certEvaluationResult: (URLSession.AuthChallengeDisposition, URLCredential?)!
    var taskCreationExpectations: [XCTestExpectation] = []

    override func setUpWithError() throws {
        mockNetworkSession = MockNetworkSession()

        let apiRequestCreationBody: (NetworkTask) -> ApiRequest = { _ in
            defer { self.createdRequestCount += 1 }
            return MockApiRequest(identifier: self.createdRequestCount)
        }

        let apiRequestCreation: ApiRequestCreation = { networkTaskCreation, onTaskCreation in
            let taskCreationExpectation = self.expectation(description: "wait for task creation")
            self.taskCreationExpectations.append(taskCreationExpectation)

            let networkTask = networkTaskCreation()
            let apiRequest = apiRequestCreationBody(networkTask)

            // emulating the behavior of RequestWithToken refresh, which calls this block async after token refresh
            DispatchQueue.global().async {
                onTaskCreation(apiRequest)
                taskCreationExpectation.fulfill()
            }
            return apiRequest
        }

        let apiRequestReconnectionCreation: (NetworkTask) -> ApiRequest = { networkTask in
            apiRequestCreationBody(networkTask)
        }

        sut = NetworkSessionManager(
            sessionCreation: { _, _ in
                self.mockNetworkSession
            },
            apiRequestReconnectionCreation: apiRequestReconnectionCreation,
            authChallengeHandler: { _ in
                self.certEvaluationResult
            }
        )
        sut.apiRequestCreation = apiRequestCreation
    }

    func testCreatingEachTaskTypeRegistersToRequestMap() throws {
        let one = sut.apiRequestData(request: { .example() }, networkTaskTag: nil)
        let two = sut.apiRequestUpload(request: { .example() }, input: .data(.init()), networkTaskTag: nil)
        let three = sut.apiRequestDownloadFile(request: { .example() }, networkTaskTag: nil)

        wait(for: taskCreationExpectations, timeout: 1)
        XCTAssert(sut.requestMap.getAllRequests().count == [one, two, three].count)
    }

    func testRequestMapDoesntStronglyRetainRequests() throws {
        _ = sut.apiRequestData(request: { .example() }, networkTaskTag: nil)
        _ = sut.apiRequestUpload(request: { .example() }, input: .data(.init()), networkTaskTag: nil)
        _ = sut.apiRequestDownloadFile(request: { .example() }, networkTaskTag: nil)

        wait(for: taskCreationExpectations, timeout: 1)
        XCTAssert(sut.requestMap.getAllRequests().count == 0)
    }

    func testURLSessionDelegateDataTaskCallbacksAreForwardedToRequest() throws {
        let dataExpectation = expectation(description: "completion called")
        let completionExpectation = expectation(description: "data recieved called")

        let request = sut.apiRequestData(request: { .example() }, networkTaskTag: "delegate-task")
        let mockRequest = try XCTUnwrap(request as? MockApiRequest)

        mockRequest.handleRecieveDataSignal = {
            dataExpectation.fulfill()
        }

        mockRequest.handleCompletionSignal = {
            completionExpectation.fulfill()
        }

        wait(for: taskCreationExpectations, timeout: 1)

        let underlyingTask = try XCTUnwrap(mockNetworkSession.tasks["delegate-task"] as? NetworkDataTask)

        sut.networkSession(mockNetworkSession, dataTask: underlyingTask, didReceive: Data())
        sut.networkSession(mockNetworkSession, task: underlyingTask, didCompleteWithError: nil)

        wait(for: [dataExpectation, completionExpectation], timeout: 1)
    }

    func testURLSessionDelegateDownloadTaskProgressCallbacksAreForwardedToRequest() throws {
        let e = expectation(description: "progress called")

        let request = sut.apiRequestDownloadFile(request: { .example() }, networkTaskTag: "delegate-task")
        wait(for: taskCreationExpectations, timeout: 1)

        let underlyingTask = try XCTUnwrap(mockNetworkSession.tasks["delegate-task"] as? NetworkDownloadTask)

        let mockRequest = try XCTUnwrap(request as? MockApiRequest)

        mockRequest.handleWroteDownloadDataSignal = {
            e.fulfill()
        }

        sut.networkSession(mockNetworkSession, downloadTask: underlyingTask, didWriteData: 2, totalBytesWritten: 2, totalBytesExpectedToWrite: 8)

        wait(for: [e], timeout: 1)
    }

    func testURLSessionDelegateDownloadTaskFinishedCallbacksAreForwardedToRequestSynchronously() throws {
        let request = sut.apiRequestDownloadFile(request: { .example() }, networkTaskTag: "delegate-task")
        wait(for: taskCreationExpectations, timeout: 1)

        let underlyingTask = try XCTUnwrap(mockNetworkSession.tasks["delegate-task"] as? NetworkDownloadTask)

        let mockRequest = try XCTUnwrap(request as? MockApiRequest)

        var pass = false
        mockRequest.handleDownloadFinishedSignal = {
            pass = true
        }

        sut.networkSession(mockNetworkSession, downloadTask: underlyingTask, didFinishDownloadingTo: .example)
        sut.networkSession(mockNetworkSession, downloadTask: underlyingTask, didWriteData: 2, totalBytesWritten: 2, totalBytesExpectedToWrite: 8)

        XCTAssertTrue(pass)
    }

    func testURLSessionDelegateUploadTaskCallbacksAreForwardedToRequest() throws {
        let e = expectation(description: "progress called")

        let request = sut.apiRequestUpload(request: { .example() }, input: .stream(.init(data: .init())), networkTaskTag: "delegate-task")
        wait(for: taskCreationExpectations, timeout: 1)

        let underlyingTask = try XCTUnwrap(mockNetworkSession.tasks["delegate-task"] as? NetworkUploadTask)
        let mockRequest = try XCTUnwrap(request as? MockApiRequest)

        sut.networkSession(mockNetworkSession, task: underlyingTask, didSendBodyData: 2, totalBytesSent: 2, totalBytesExpectedToSend: 8)

        mockRequest.handleSentBodyDataSignal = {
            e.fulfill()
        }

        wait(for: [e], timeout: 1)
    }

    func testURLSessionDelegateProcessesAndPropogatesCertEvaluationClosure() throws {
        let e = expectation(description: "completion called")

        certEvaluationResult = (.cancelAuthenticationChallenge, nil)

        sut.networkSession(mockNetworkSession, didReceive: URLAuthenticationChallenge()) { disposition, credential in
            XCTAssertEqual(
                disposition,
                self.certEvaluationResult.0
            )
            XCTAssertEqual(
                credential,
                self.certEvaluationResult.1
            )
            e.fulfill()
        }

        wait(for: [e], timeout: 1)
    }

    func testShutdownInvalidatesNetworkSession() throws {
        sut.shutdown()
        XCTAssert(mockNetworkSession.invalidateCalled)
    }

    func testShutdownManagerProvidersNoopApiRequests() throws {
        sut.shutdown()

        let apiRequest = sut.apiRequestData(request: { .example() }, networkTaskTag: nil)

        XCTAssert(apiRequest is NoopApiRequest)
        XCTAssert(apiRequest.networkTask is NoopNetworkTask)
    }
}

// MARK:

func URLAuthenticationChallenge() -> URLAuthenticationChallenge {
    .init(
        protectionSpace:
        .init(
            host: "www.dropbox.com",
            port: 80,
            protocol: NSURLProtectionSpaceHTTPS,
            realm: nil,
            authenticationMethod: NSURLAuthenticationMethodServerTrust
        ),
        proposedCredential: nil,
        previousFailureCount: 0,
        failureResponse: nil,
        error: nil,
        sender: MockURLAuthenticationChallengeSender()
    )
}

extension URL {
    static var example: URL {
        .init(string: "/files/file.tpm")!
    }
}

class MockURLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    func cancel(_ challenge: URLAuthenticationChallenge) {}
}
