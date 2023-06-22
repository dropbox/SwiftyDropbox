//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

// MARK: Types

public protocol NetworkTask: AnyObject {
    func resume()
    func cancel()
    var response: URLResponse? { get }
    var error: Error? { get }
    var clientError: ClientError? { get }
    var originalRequest: URLRequest? { get }
    var taskIdentifier: Int { get }
    var taskDescription: String? { get set }

    @available(iOS 13.0, macOS 10.13, *)
    var earliestBeginDate: Date? { get set }
}

public extension NetworkTask {
    var clientError: ClientError? {
        error.map { .urlSessionError($0) }
    }
}

public typealias NetworkTaskTag = String

// TODO: are these needed
public protocol NetworkDataTask: NetworkTask {}
public protocol NetworkUploadTask: NetworkTask {}
public protocol NetworkDownloadTask: NetworkTask {}

public typealias NetworkDataTaskCompletion = (NetworkDataTaskResult) -> Void

public enum NetworkTaskFailure: Error {
    case badStatusCode(data: Data, code: NetworkStatusCode, response: HTTPURLResponse)
    case failedWithError(ClientError)
}

public typealias NetworkDataTaskResult = Result<(data: Data, response: HTTPURLResponse), NetworkTaskFailure>
public typealias NetworkDownloadTaskResult = Result<(url: URL, response: HTTPURLResponse), NetworkTaskFailure>

public typealias NetworkStatusCode = Int

extension NetworkStatusCode {
    var isSuccessful: Bool {
        (200 ..< 300).contains(self)
    }

    init(_ int: Int) {
        self = int
    }
}

// MARK: Implementations

extension URLSessionTask: NetworkTask {}
extension URLSessionDataTask: NetworkDataTask {}
extension URLSessionUploadTask: NetworkUploadTask {}
extension URLSessionDownloadTask: NetworkDownloadTask {}

extension NetworkDataTaskResult {
    init(data: Data?, response: URLResponse?, error: ClientError?) {
        if let response = response as? HTTPURLResponse {
            let data = data ?? .init()

            if NetworkStatusCode(response.statusCode).isSuccessful {
                self = .success((data, response))
            } else {
                self = .failure(
                    .badStatusCode(
                        data: data,
                        code: response.statusCode,
                        response: response
                    )
                )
            }
        } else if let error = error {
            self = .failure(.failedWithError(error))
        } else {
            self = .failure(.failedWithError(.unexpectedState))
        }
    }
}

extension NetworkDownloadTaskResult {
    init(url: URL?, response: URLResponse?, error: ClientError?, errorDataFromLocation: (URL) throws -> Data) {
        if let url = url, let response = response as? HTTPURLResponse {
            if NetworkStatusCode(response.statusCode).isSuccessful {
                self = .success((url, response))
            } else {
                do {
                    self = .failure(
                        .badStatusCode(
                            data: try errorDataFromLocation(url),
                            code: response.statusCode,
                            response: response
                        )
                    )
                } catch {
                    self = .failure(.failedWithError(.fileAccessError(error)))
                }
            }
        } else if let error = error {
            self = .failure(.failedWithError(error))
        } else {
            self = .failure(.failedWithError(.unexpectedState))
        }
    }
}
