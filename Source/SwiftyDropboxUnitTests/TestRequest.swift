///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

@testable import SwiftyDropbox
import XCTest

final class TestRequest: XCTestCase {
    var sut: DownloadRequestFile<Files.FileMetadataSerializer, Files.DownloadErrorSerializer>!
    var mockApiRequest: MockApiRequest!
    var apiRequest: ApiRequest!
    var mockTask: MockNetworkTaskDelegate!
    var persistedInfo: ReconnectionHelpers.PersistedRequestInfo!

    func setUp(with authStrategy: AuthStrategy, taskCreationExpectation: XCTestExpectation? = nil) throws {
        mockTask = MockNetworkTaskDelegate(request: .example())
        apiRequest = RequestWithTokenRefresh(
            requestCreation: { self.mockTask },
            onTaskCreation: { _ in taskCreationExpectation?.fulfill() },
            authStrategy: authStrategy,
            filesAccess: FilesAccessImpl(fileManager: MockFileManager())
        )

        sut = DownloadRequestFile<Files.FileMetadataSerializer, Files.DownloadErrorSerializer>(
            request: apiRequest,
            responseSerializer: Files.FileMetadataSerializer(),
            errorSerializer: Files.DownloadErrorSerializer(),
            moveToDestination: { url in url },
            errorDataFromLocation: { _ in Data() }
        )

        persistedInfo = ReconnectionHelpers.PersistedRequestInfo.downloadFile(
            .init(
                originalSDKVersion: DropboxClientsManager.sdkVersion,
                routeName: "downloadRequestFile",
                routeNamespace: "Files",
                clientProvidedInfo: nil,
                destination: .example,
                overwrite: false
            )
        )

        apiRequest.taskDescription = try? persistedInfo.asJsonString()
    }

    func testSettingPersistentStringBeforeTaskCreation() throws {
        let expectation = expectation(description: "task creation")
        try setUp(with: .accessToken(MockAccessTokenProvider()), taskCreationExpectation: expectation)
        let persistedString = "persist this"
        let _ = sut.persistingString(string: persistedString)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sut.clientPersistedString, persistedString)
    }

    func testSettingPersistentStringAfterTaskCreation() throws {
        let expectation = expectation(description: "task creation")
        try setUp(with: .accessToken(MockAccessTokenProvider()), taskCreationExpectation: expectation)
        wait(for: [expectation], timeout: 1)
        let persistedString = "persist this"
        let _ = sut.persistingString(string: persistedString)
        XCTAssertEqual(sut.clientPersistedString, persistedString)
    }

    @available(iOS 13.0, macOS 10.13, *)
    func testSettingEarliestBeginDateBeforeTaskCreation() throws {
        let expectation = expectation(description: "task creation")
        try setUp(with: .accessToken(MockAccessTokenProvider()), taskCreationExpectation: expectation)
        let date = Date(timeIntervalSince1970: 0)
        let _ = sut.settingEarliestBeginDate(date: date)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sut.earliestBeginDate, date)
    }

    @available(iOS 13.0, macOS 10.13, *)
    func testSettingEarliestBeginDateAfterTaskCreation() throws {
        let expectation = expectation(description: "task creation")
        try setUp(with: .accessToken(MockAccessTokenProvider()), taskCreationExpectation: expectation)
        wait(for: [expectation], timeout: 1)
        let date = Date(timeIntervalSince1970: 0)
        let _ = sut.settingEarliestBeginDate(date: date)
        XCTAssertEqual(sut.earliestBeginDate, date)
    }

    func testSelfRetainRetains() throws {
        try setUp(with: .accessToken(MockAccessTokenProvider()))

        weak var request = sut
        sut = nil
        XCTAssertNotNil(request)
    }

    func testSelfRetainEndsAfterCompletionExecution() throws {
        try setUp(with: .accessToken(MockAccessTokenProvider()))

        let e = expectation(description: "completion handler")
        weak var request = sut
        sut = nil

        // Request will be retained until completion handler is called
        request?.response(completionHandler: { _, _ in
            e.fulfill()
        })

        apiRequest.handleCompletion(error: nil)

        wait(for: [e], timeout: 1)

        XCTAssertNil(request)
    }

    func testUnderlyingRequestIsCalledWithAppAuth() throws {
        let e = expectation(description: "task created")
        try setUp(with: .appKeyAndSecret("key", "secret"), taskCreationExpectation: e)
        wait(for: [e], timeout: 1)
        XCTAssert(mockTask.resumeCalled)
    }
}
