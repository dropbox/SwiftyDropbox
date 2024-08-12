///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

class TestRequestWithTokenRefresh: XCTestCase {
    var sut: RequestWithTokenRefresh!
    var mockAccessTokenProvider: MockAccessTokenProvider!
    var mockFileManager: MockFileManager!
    var mockFilesAccess: FilesAccess!

    override func setUpWithError() throws {
        mockAccessTokenProvider = MockAccessTokenProvider()
        mockFileManager = MockFileManager()
        mockFilesAccess = FilesAccessImpl(fileManager: mockFileManager)
        DropboxTransportClientImpl.serializeOnBackgroundThread = false
    }

    // MARK: Handing oauth outcomes

    func testThatOriginalRequestResumesAfterOauthRequestSucceeds() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let expectation = expectation(description: "wait for task creation")

        // When
        mockAccessTokenProvider.result = .success(.init(accessToken: "access-token", uid: "123abc"))
        sut = makeRequestWithTokenRefresh(expectationFulfilledOnTaskCreation: expectation, request: urlTask)

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssert(urlTask.resumeCalled)
    }

    func testThatOriginalRequestDoesNotResumeAndCompletionCalledAfterOauthRequestFails() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let e = expectation(description: "completion called")

        // When
        mockAccessTokenProvider.result = .error(.accessDenied, "error")
        sut = makeRequestWithTokenRefresh(request: urlTask)

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .dataCompletionHandlerProvider({ result in
                XCTAssertEqual(
                    result.innerError as? ClientError,
                    ClientError.oauthError(OAuth2Error.accessDenied)
                )
                return {
                    e.fulfill()
                }
            })
        )

        // Then
        wait(for: [e], timeout: 1)
        XCTAssertFalse(urlTask.resumeCalled)
    }

    // MARK: Handling inputs via delegate

    func testThatIncomingDataIsAppendedToExistingData() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let testDataOne = Data("test-data-one".utf8)
        let testDataTwo = Data("test-data-two".utf8)

        var expectedResult = testDataOne
        expectedResult.append(testDataTwo)

        // When
        sut = makeRequestWithTokenRefresh(request: urlTask)
        sut.handleRecieve(data: testDataOne)
        sut.handleRecieve(data: testDataTwo)

        // Then
        _ = XCTWaiter.wait(for: [expectation(description: "wait for async")], timeout: 0.1)

        XCTAssert(urlTask.resumeCalled)

        XCTAssertEqual(
            String(data: sut.__test_only_mutableState.data, encoding: .utf8),
            String(data: expectedResult, encoding: .utf8)
        )
    }

    func testThatACompletedDataTaskVendsDataInCompletionHandler() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let testData = Data("test-data-one".utf8)
        let completionCalledExpectaion = expectation(description: "completion called")
        let taskCreatedExpectation = expectation(description: "task created")

        // When
        sut = makeRequestWithTokenRefresh(expectationFulfilledOnTaskCreation: taskCreatedExpectation, request: urlTask)

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .dataCompletionHandlerProvider({ result in
                XCTAssertEqual(
                    String(data: result.successData ?? .init(), encoding: .utf8),
                    String(data: testData, encoding: .utf8)
                )
                return {
                    completionCalledExpectaion.fulfill()
                }
            })
        )

        sut.handleRecieve(data: testData)
        urlTask.response = successfulResponse()

        // Must wait for the task to be set before we call the completion handler
        wait(for: [taskCreatedExpectation], timeout: 1)
        sut.handleCompletion(error: nil)

        // Then
        wait(for: [completionCalledExpectaion], timeout: 1)
    }

    func testThatUploadProgressIsReportedThroughProgressHandlers() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let e = expectation(description: "completion called")

        // When
        sut = makeRequestWithTokenRefresh(request: urlTask)
        _ = sut.setProgressHandler { progress in
            XCTAssertEqual(
                0.25,
                progress.fractionCompleted
            )
            e.fulfill()
        }

        sut.handleSentBodyData(totalBytesSent: 2, totalBytesExpectedToSend: 8)

        // Then
        wait(for: [e], timeout: 1)
    }

    func testThatDownloadProgressIsReportedThroughProgressHandlers() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let e = expectation(description: "completion called")

        // When
        sut = makeRequestWithTokenRefresh(request: urlTask)
        _ = sut.setProgressHandler { progress in
            XCTAssertEqual(
                0.25,
                progress.fractionCompleted
            )
            e.fulfill()
        }

        sut.handleWroteDownloadData(totalBytesWritten: 2, totalBytesExpectedToWrite: 8)

        // Then
        wait(for: [e], timeout: 1)
    }

    // MARK: Threading

    func testThatCompletionHandlerDefaultsToMainThread() throws {
        // Given
        let e = expectation(description: "completion called")

        // When
        sut = makeRequestWithTokenRefresh()

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .dataCompletionHandlerProvider({ _ in
                {
                    XCTAssert(Thread.isMainThread)
                    e.fulfill()
                }
            })
        )
        sut.handleCompletion(error: nil)

        // Then
        wait(for: [e], timeout: 1)
    }

    func testThatCompletionHandlerThreadCanBeOverriden() throws {
        // Given
        let e = expectation(description: "completion called")

        // When
        sut = makeRequestWithTokenRefresh()

        _ = sut.setCompletionHandlerProvider(
            queue: DispatchQueue.global(qos: .default),
            completionHandlerProvider: .dataCompletionHandlerProvider({ _ in
                {
                    XCTAssertFalse(Thread.isMainThread)
                    e.fulfill()
                }
            })
        )
        sut.handleCompletion(error: nil)

        // Then
        wait(for: [e], timeout: 1)
    }

    func testThatSerializationThreadCanBeSetToBackgroundThread() throws {
        // Given
        let e = expectation(description: "completion called")
        DropboxTransportClientImpl.serializeOnBackgroundThread = true

        // When
        sut = makeRequestWithTokenRefresh()

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .dataCompletionHandlerProvider({ _ in
                // deserialization context
                XCTAssertFalse(Thread.isMainThread)
                return {
                    // completion context
                    XCTAssertTrue(Thread.isMainThread)
                    e.fulfill()
                }
            })
        )
        sut.handleCompletion(error: nil)

        // Then
        wait(for: [e], timeout: 1)
    }

    func testThatSerializationThreadDefaultsToCompletionThread() throws {
        // Given
        let e = expectation(description: "completion called")

        // When
        sut = makeRequestWithTokenRefresh()

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .dataCompletionHandlerProvider({ _ in
                // deserialization context
                XCTAssertTrue(Thread.isMainThread)
                return {
                    // completion context
                    XCTAssertTrue(Thread.isMainThread)
                    e.fulfill()
                }
            })
        )
        sut.handleCompletion(error: nil)

        // Then
        wait(for: [e], timeout: 1)
    }

    func testThatOauthFailureCompletionCallWillNotDeadlock() throws {
        // Given
        let e = expectation(description: "reached end of completion block")

        // When
        mockAccessTokenProvider.result = .error(.accessDenied, "error")
        sut = makeRequestWithTokenRefresh()

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .dataCompletionHandlerProvider({ _ in
                {
                    // This cancel call toggles the sut's internal lock
                    self.sut.cancel()

                    e.fulfill()
                }
            })
        )

        // Then
        wait(for: [e], timeout: 1)
    }

    func testThatCompletionHandlerCallWillNotDeadlock() throws {
        // Given
        let e = expectation(description: "reached end of completion block")

        // When
        sut = makeRequestWithTokenRefresh()

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .dataCompletionHandlerProvider({ _ in
                {
                    // This cancel call toggles the sut's internal lock
                    self.sut.cancel()

                    e.fulfill()
                }
            })
        )
        sut.handleCompletion(error: nil)

        // Then
        wait(for: [e], timeout: 1)
    }

    func testThatLateSetCompletionHandlerCallWillNotDeadlock() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let e = expectation(description: "reached end of completion block")

        // When
        sut = makeRequestWithTokenRefresh(request: urlTask)

        urlTask.response = successfulResponse()
        sut.handleCompletion(error: nil)

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .dataCompletionHandlerProvider({ _ in
                {
                    // This cancel call toggles the sut's internal lock
                    self.sut.cancel()
                    e.fulfill()
                }
            })
        )

        // Then
        wait(for: [e], timeout: 1)
    }

    // MARK: Adding completion handler late

    func testThatACompletionHandlerIsCalledIfSetAfterTaskCompletion() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let e = expectation(description: "completion called")

        // When
        sut = makeRequestWithTokenRefresh(request: urlTask)

        urlTask.response = successfulResponse()
        sut.handleCompletion(error: nil)

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .dataCompletionHandlerProvider({ _ in
                {
                    e.fulfill()
                }
            })
        )

        // Then
        wait(for: [e], timeout: 1)
    }

    // MARK: Downloads

    func testThatDownloadedFileIsWrittenToSpecifiedLocation() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let completionExpectation = expectation(description: "completion called")
        let taskCreationExpectation = expectation(description: "task created")

        // When
        sut = makeRequestWithTokenRefresh(expectationFulfilledOnTaskCreation: taskCreationExpectation, request: urlTask)

        let myFile = "my-file".data(using: .utf8)

        let tempDownloadLocation = try XCTUnwrap(URL(string: UUID().uuidString))
        mockFileManager.addFile(data: myFile, at: tempDownloadLocation)

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .downloadFileCompletionHandlerProvider({ result in
                if case .success((let url, _)) = result {
                    let completionData = self.mockFileManager.contents(at: url)
                    XCTAssertEqual(completionData, myFile)
                } else {
                    XCTFail()
                }

                return {
                    completionExpectation.fulfill()
                }
            })
        )

        urlTask.response = successfulResponse()

        // Must wait as download finished assumes that the request has been set
        wait(for: [taskCreationExpectation], timeout: 1)
        sut.handleDownloadFinished(location: tempDownloadLocation)
        sut.handleCompletion(error: nil)

        // Then
        wait(for: [completionExpectation], timeout: 1)
    }

    func testThatDownloadErrorIsPresentInCompletionHandler() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let completionExpectation = expectation(description: "completion called")
        let taskCreationExpectation = expectation(description: "task created")

        // When
        sut = makeRequestWithTokenRefresh(expectationFulfilledOnTaskCreation: taskCreationExpectation, request: urlTask)

        let error = Files.DownloadError.unsupportedFile
        let errorJson = try Files.DownloadErrorSerializer().serialize(error)
        let errorJsonData = try SerializeUtil.dumpJSON(errorJson)

        let tempDownloadLocation = try XCTUnwrap(URL(string: UUID().uuidString))
        mockFileManager.addFile(data: errorJsonData, at: tempDownloadLocation)

        urlTask.response = routeErrorResponse()

        // Must wait as download finished assumes that the request has been set
        wait(for: [taskCreationExpectation], timeout: 1)
        sut.handleDownloadFinished(location: tempDownloadLocation)
        sut.handleCompletion(error: nil)

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .downloadFileCompletionHandlerProvider({ result in
                if case .failure(let networkTaskFailure) = result {
                    if case .badStatusCode(let completionData, _, _) = networkTaskFailure {
                        XCTAssertEqual(completionData, errorJsonData)
                    }
                }
                return {
                    completionExpectation.fulfill()
                }
            })
        )

        // Then
        wait(for: [completionExpectation], timeout: 1)
    }

    func testThatDownloadErrorIsPresentInLateSetCompletionHandler() throws {
        // Given
        let urlTask = MockNetworkTaskDelegate(request: .example())
        let completionExpectation = expectation(description: "completion called")
        let taskCreationExpectation = expectation(description: "task created")

        // When
        sut = makeRequestWithTokenRefresh(expectationFulfilledOnTaskCreation: taskCreationExpectation, request: urlTask)

        urlTask.response = successfulResponse()

        let routeResult = Check.EchoResult(result: "test")
        let routeJson = try Check.EchoResultSerializer().serialize(routeResult)
        let routeJsonData = try SerializeUtil.dumpJSON(routeJson)

        let tempDownloadLocation = try XCTUnwrap(URL(string: UUID().uuidString))
        mockFileManager.addFile(data: routeJsonData, at: tempDownloadLocation)

        // Must wait as download finished assumes that the request has been set
        wait(for: [taskCreationExpectation], timeout: 1)
        sut.handleDownloadFinished(location: tempDownloadLocation)
        sut.handleCompletion(error: nil)

        _ = sut.setCompletionHandlerProvider(
            queue: nil,
            completionHandlerProvider: .downloadFileCompletionHandlerProvider({ result in
                if case .success((let url, _)) = result {
                    let completionData = self.mockFileManager.contents(at: url)
                    XCTAssertEqual(completionData, routeJsonData)
                } else {
                    XCTFail()
                }

                return {
                    completionExpectation.fulfill()
                }
            })
        )

        // Then
        wait(for: [completionExpectation], timeout: 1)
    }

    fileprivate func makeRequestWithTokenRefresh(
        expectationFulfilledOnTaskCreation expectation: XCTestExpectation? = nil,
        request: NetworkTask = MockNetworkTaskDelegate(request: .example())
    ) -> RequestWithTokenRefresh {
        RequestWithTokenRefresh(
            requestCreation: { request },
            onTaskCreation: { _ in
                expectation?.fulfill()
            },
            authStrategy: .accessToken(mockAccessTokenProvider),
            filesAccess: mockFilesAccess
        )
    }
}

// MARK: Helpers

extension URLRequest {
    static func example() -> URLRequest {
        URLRequest(url: .init(string: "www.example.com")!)
    }
}

class MockAccessTokenProvider: AccessTokenProvider {
    var result: DropboxOAuthResult?

    private let queue = DispatchQueue(
        label: "com.dropbox.SwiftyDropbox.MockAccessTokenProvider.queue",
        qos: .userInitiated,
        attributes: .concurrent
    )

    var accessToken: String = "accessToken"
    func refreshAccessTokenIfNecessary(completion: @escaping DropboxOAuthCompletion) {
        // If the result is a failure, we immediately call the completion handler.
        // In test, in that case, there is a race between calling and setting the completion handler.
        // In real life, there isn't a race, because some network call is always made:
        // oauth failures only come in server reponses, and successes lead to a post-auth call.

        queue.asyncAfter(deadline: .now() + .milliseconds(10)) {
            completion(self.result)
        }
    }
}

private func successfulResponse() -> HTTPURLResponse {
    .init(url: .init(string: "www.example.com")!, statusCode: 200, httpVersion: "1.0", headerFields: [:])!
}

private func routeErrorResponse() -> HTTPURLResponse {
    .init(url: .init(string: "www.example.com")!, statusCode: 409, httpVersion: "1.0", headerFields: [:])!
}

extension NetworkDataTaskResult {
    var innerError: Error? {
        if case .failure(let dataTaskError) = self {
            if case .failedWithError(let innerError) = dataTaskError {
                return innerError
            }
        }
        return nil
    }

    var successData: Data? {
        if case .success((let data, _)) = self {
            return data
        }
        return nil
    }
}

class MockFileManager {
    var files: [String: Data] = [:]

    func addFile(data: Data?, at location: URL) {
        files[location.path] = data
    }

    func contents(at location: URL) -> Data? {
        files[location.path]
    }
}

extension MockFileManager: FileManagerProtocol {
    func contents(atPath: String) -> Data? {
        files[atPath]
    }

    func fileExists(atPath path: String) -> Bool {
        files[path] != nil
    }

    func createDirectory(at url: URL, withIntermediateDirectories: Bool, attributes: [FileAttributeKey: Any]?) throws {
        // no-op
    }

    func moveItem(atPath: String, toPath: String) throws {
        files[toPath] = files[atPath]
        files[atPath] = nil
    }

    func moveItem(at atUrl: URL, to toUrl: URL) throws {
        try moveItem(atPath: atUrl.path, toPath: toUrl.path)
    }

    func removeItem(at url: URL) throws {
        files[url.path] = nil
    }
}

#if compiler(>=6)
extension ClientError: @retroactive RawRepresentable, @retroactive Equatable {
    public typealias RawValue = String

    public init?(rawValue: String) {
        fatalError("unimplemented")
    }

    public var rawValue: String {
        switch self {
        case .oauthError:
            return "oauthError"
        case .urlSessionError:
            return "urlSessionError"
        case .fileAccessError:
            return "fileAccessError"
        case .requestObjectDeallocated:
            return "requestObjectDeallocated"
        case .unexpectedState:
            return "unexpectedState"
        case .other:
            return "unknown"
        }
    }
}
#else
extension ClientError: RawRepresentable, Equatable {
    public typealias RawValue = String

    public init?(rawValue: String) {
        fatalError("unimplemented")
    }

    public var rawValue: String {
        switch self {
        case .oauthError:
            return "oauthError"
        case .urlSessionError:
            return "urlSessionError"
        case .fileAccessError:
            return "fileAccessError"
        case .requestObjectDeallocated:
            return "requestObjectDeallocated"
        case .unexpectedState:
            return "unexpectedState"
        case .other:
            return "unknown"
        }
    }
}
#endif
