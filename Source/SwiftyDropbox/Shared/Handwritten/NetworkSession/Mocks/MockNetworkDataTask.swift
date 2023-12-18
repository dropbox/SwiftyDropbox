//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

class MockNetworkTaskDelegate: NetworkDataTask, NetworkDownloadTask, NetworkUploadTask {
    var error: Error?
    var response: URLResponse?
    var originalRequest: URLRequest?
    var taskIdentifier: Int = 0
    var taskDescription: String?
    var earliestBeginDate: Date?

    // MARK: Test utils

    var resumeCalled: Bool = false
    var cancelCalled: Bool = false

    init(request: URLRequest) {
        self.originalRequest = request
    }

    func resume() {
        resumeCalled = true
    }

    func cancel() {
        cancelCalled = true
    }
}

class MockNetworkDataTaskCompletion: NetworkDataTask {
    var error: Error?
    var state: URLSessionTask.State = .suspended
    var response: URLResponse?
    var originalRequest: URLRequest?
    var taskIdentifier: Int = 0
    var taskDescription: String?
    var earliestBeginDate: Date?
    var completionHandler: NetworkDataTaskCompletion
    var mockInput: () -> MockInput?

    init(request: URLRequest, mockInput: @escaping () -> MockInput? = { nil }, completionHandler: @escaping NetworkDataTaskCompletion) {
        self.originalRequest = request
        self.mockInput = mockInput
        self.completionHandler = completionHandler
    }

    func resume() {
        let result: NetworkDataTaskResult
        let mockInput = mockInput() ?? .none

        do {
            switch mockInput {
            case .none:
                result = .failure(.failedWithError(.other(MockNetworkTaskResultError.noMockResultProvided)))

            case .routeError, .downloadSuccess:
                fatalError("route and download calls use the delegate task")

            case .requestError(let json, let code):
                let (data, response) = try MockTaskHelpers.createResultComponents(task: self, json: json, code: code)
                result = .failure(.badStatusCode(data: data, code: code, response: response))

            case .success(let json):
                let (data, response) = try MockTaskHelpers.createResultComponents(task: self, json: json, code: 200)
                result = .success((data: data, response: response))
            case .clientError(error: let error):
                result = .failure(.failedWithError(error))
            }
        } catch {
            result = .failure(.failedWithError(.other(error)))
        }

        completionHandler(result)
    }

    func cancel() {
        fatalError("todo")
    }
}

enum MockTaskHelpers {
    static func createResultComponents(task: NetworkTask, json: [String: Any], code: NetworkStatusCode) throws -> (Data, HTTPURLResponse) {
        let originalRequest = try task.originalRequest.orThrow()
        let url = try originalRequest.url.orThrow(MockNetworkTaskResultError.badMockResultProvided)

        return try createResultComponents(requestUrl: url, json: json, code: code)
    }

    static func createResultComponents(requestUrl: URL, json: [String: Any], code: NetworkStatusCode) throws -> (Data, HTTPURLResponse) {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try HTTPURLResponse(url: requestUrl, statusCode: code, httpVersion: "HTTP/2.0", headerFields: [:])
                .orThrow(MockNetworkTaskResultError.badMockResultProvided)
            return (data: data, response: response)
        } catch {
            throw MockNetworkTaskResultError.badMockResultProvided
        }
    }

    static func createDownloadResultComponents(requestUrl: URL, json: [String: Any], code: NetworkStatusCode) throws -> (Data, HTTPURLResponse) {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try HTTPURLResponse(
                url: requestUrl,
                statusCode: code,
                httpVersion: "HTTP/2.0",
                headerFields: ["Dropbox-Api-Result": toSerializedString(json: json)]
            ).orThrow(MockNetworkTaskResultError.badMockResultProvided)

            return (data: data, response: response)
        } catch {
            throw MockNetworkTaskResultError.badMockResultProvided
        }
    }

    private static func toSerializedString(json: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        guard let string = String(data: data, encoding: .utf8) else {
            throw MockNetworkTaskResultError.badMockResultProvided
        }

        return string
    }
}

enum MockNetworkTaskResultError: Error {
    case noMockResultProvided
    case badMockResultProvided
}
