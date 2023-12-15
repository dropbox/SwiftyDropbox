///
/// Copyright (c) 2023 Dropbox, Inc. All rights reserved.
///

import Foundation

class MockApiRequest: ApiRequest {
    var handleCompletionSignal: (() -> Void)?
    var handleRecieveDataSignal: (() -> Void)?
    var handleDownloadFinishedSignal: (() -> Void)?
    var handleSentBodyDataSignal: (() -> Void)?
    var handleWroteDownloadDataSignal: (() -> Void)?

    var networkTask: NetworkTask? {
        fatalError()
    }

    var requestUrl: URL?
    var completionHandler: RequestCompletionHandler? {
        didSet {
            guard completionHandler != nil else {
                return
            }
            mockInput.flatMap { try? _handleMockInput($0) }
            mockInput = nil
        }
    }

    /// If the completionHandler is not set yet, we keep around MockInput so we can call it later
    private var mockInput: MockInput?

    public init(identifier: Int = Int.random(in: 1 ..< Int.max), requestUrl: URL? = nil) {
        self.identifier = identifier
        self.requestUrl = requestUrl
    }

    var identifier: Int
    var taskDescription: String?
    var earliestBeginDate: Date?

    func handleCompletion(error: ClientError?) {
        handleCompletionSignal?()
    }

    func handleRecieve(data: Data) {
        handleRecieveDataSignal?()
    }

    func handleDownloadFinished(location: URL) {
        handleDownloadFinishedSignal?()
    }

    func handleSentBodyData(totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        handleSentBodyDataSignal?()
    }

    func handleWroteDownloadData(totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        handleWroteDownloadDataSignal?()
    }

    func setProgressHandler(_ handler: @escaping (Progress) -> Void) -> Self { self }

    func setCompletionHandler(queue: DispatchQueue?, completionHandler: RequestCompletionHandler) -> Self {
        self.completionHandler = completionHandler
        return self
    }

    func cancel() {}

    func setCleanupHandler(_ handler: @escaping () -> Void) {}
}

extension MockApiRequest {
    func handleMockInput(_ mockInput: MockInput) throws {
        try _handleMockInput(mockInput)
    }

    func handleMockInput(_ mockInput: MockInputWithModel) throws {
        var mappedInput: MockInput

        switch mockInput {
        case .none:
            mappedInput = .none
        case .success(let model):
            mappedInput = .success(json: try MockingUtilities.jsonObject(from: model))
        case .downloadSuccess(let model, let downloadLocation):
            mappedInput = .downloadSuccess(json: try MockingUtilities.jsonObject(from: model), downloadLocation: downloadLocation)
        case .requestError(let model, let code):
            mappedInput = .requestError(json: try MockingUtilities.jsonObject(from: model), code: code)
        case .routeError(let model):
            mappedInput = .success(json: try MockingUtilities.jsonObject(from: model))
        }

        try _handleMockInput(mappedInput)
    }
}

enum MockApiRequestError: Error {
    case badApiRequestType
}

extension MockApiRequest {
    func _handleMockInput(_ mockInput: MockInput) throws {
        guard completionHandler != nil else {
            self.mockInput = mockInput
            return
        }

        func callCompletion(data: Data?, response: HTTPURLResponse?, error: Error?, downloadLocation: URL? = nil) {
            switch completionHandler {
            case .dataCompletionHandler(let handler):
                handler(.init(
                    data: data,
                    response: response,
                    error: error.flatMap { .urlSessionError($0) }
                ))
            case .downloadFileCompletionHandler(let handler):
                handler(.init(
                    url: downloadLocation,
                    response: response,
                    error: error.flatMap { .urlSessionError($0) },
                    errorDataFromLocation: { _ in .init() }
                ))
            case .none:
                break
            }
        }

        switch mockInput {
        case .none:
            break
        case .routeError(let json):
            let (data, response) = try MockTaskHelpers.createResultComponents(requestUrl: requestUrl.orThrow(), json: json, code: 409)

            callCompletion(data: data, response: response, error: nil)
        case .success(let json):
            let (data, response) = try MockTaskHelpers.createResultComponents(requestUrl: requestUrl.orThrow(), json: json, code: 200)

            callCompletion(data: data, response: response, error: nil)
        case .downloadSuccess(json: let json, downloadLocation: let downloadLocation):
            let (data, response) = try MockTaskHelpers.createDownloadResultComponents(requestUrl: requestUrl.orThrow(), json: json, code: 200)

            callCompletion(data: data, response: response, error: nil, downloadLocation: downloadLocation)
        case .requestError(let json, let code):
            let (data, response) = try MockTaskHelpers.createResultComponents(requestUrl: requestUrl.orThrow(), json: json, code: code)
            let error = NSError(domain: "MockNetworkSession", code: code, userInfo: nil)

            callCompletion(data: data, response: response, error: error)
        case .clientError(error: let error):
            callCompletion(data: nil, response: nil, error: error)
        }
    }
}
