//
//  Copyright (c) 2023 Dropbox Inc. All rights reserved.
//

import Foundation

public protocol HasRequestResponse {
    associatedtype ValueType
    associatedtype ESerial: JSONSerializer

    @discardableResult
    func response(
        queue: DispatchQueue?,
        completionHandler: @escaping (ValueType?, CallError<ESerial.ValueType>?) -> Void
    ) -> Self
}

@available(iOS 13.0, macOS 10.15, *)
extension HasRequestResponse {
    /// Async wrapper for retrieving a request's response
    ///
    /// This could have a better name, but this avoids a collision with the other `response` methods
    public func responseResult(
    ) async -> Result<ValueType, CallError<ESerial.ValueType>> {
        await withCheckedContinuation { continuation in
            self.response(queue: nil) { result, error in
                if let result {
                    continuation.resume(returning: .success(result))
                } else if let error {
                    continuation.resume(returning: .failure(error))
                } else {
                    // this should never happen
                    continuation.resume(returning: .failure(.clientError(.unexpectedState)))
                }
            }
        }
    }

    /// Async wrapper for retrieving a request's response
    ///
    /// Same thing as `responseResult` but using async throws instead of returing a Result
    public func response(
    ) async throws -> ValueType {
        try await responseResult().get()
    }
}

extension RpcRequest: HasRequestResponse {}
extension UploadRequest: HasRequestResponse {}
extension DownloadRequestFile: HasRequestResponse {}
extension DownloadRequestMemory: HasRequestResponse {}
