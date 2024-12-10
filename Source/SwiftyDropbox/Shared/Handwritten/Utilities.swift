//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

// MARK: Coding

enum Utilities {
    static func utf8Decode(_ data: Data) -> String {
        NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }

    static func asciiEscape(_ s: String) -> String {
        var out: String = ""
        out.reserveCapacity(s.maximumLengthOfBytes(using: .utf16))

        for char in s.utf16 {
            var esc: String
            if let unicodeScalar = Unicode.Scalar(char), unicodeScalar.isASCII {
                esc = "\(unicodeScalar)"
            } else {
                esc = String(format: "\\u%04x", char)
            }
            out += esc
        }
        return out
    }
}

typealias RequestParameters = [String: String]
extension RequestParameters {
    func asUrlEncodedString() -> String? {
        var components = URLComponents()
        components.queryItems = []

        let urlString = map { URLQueryItem(name: $0, value: $1) }
            .reduce(into: components) { partialResult, nextItem in
                partialResult.queryItems?.append(nextItem)
            }
            .url?.query

        return urlString
    }
}

// MARK: Optionals

extension Optional {
    func orThrow(_ error: @autoclosure () -> Error) throws -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            throw error()
        }
    }

    func orThrow(file: String = #file, line: UInt = #line, function: String = #function) throws -> Wrapped {
        try orThrow(DefaultMissingValueError(file: file, line: line, function: function))
    }
}

class DefaultMissingValueError: Error {
    public var description: String
    init(file: String, line: UInt, function: String) {
        self.description = "file: \(file) line: \(line) function: \(function) unexpectedly found nil"
    }
}

/// Extend `orThrow` to double-optionals
protocol SomeOptional {
    associatedtype Wrapped
    func orThrow(_ error: @autoclosure () -> Error) throws -> Wrapped
    func orThrow(file: String, line: UInt, function: String) throws -> Wrapped
}

extension Optional: SomeOptional {}

extension Optional where Wrapped: SomeOptional {
    func orThrow(_ error: @autoclosure () -> Error) throws -> Wrapped.Wrapped {
        try orThrow(error()).orThrow(error())
    }

    func orThrow(file: String = #file, line: UInt = #line, function: String = #function) throws -> Wrapped.Wrapped {
        try orThrow(DefaultMissingValueError(file: file, line: line, function: function))
    }
}

// MARK: Logging

public enum LogLevel {
    case error
    case info
    case debug
}

public typealias LoggingClosure = (LogLevel, String) -> Void

public enum LogHelper {
    /// Adjust this upwards if needed while debugging background sessions.
    public static let backgroundSessionLogLevel: LogLevel = .debug

    /// Prepended to all SwiftyDropbox log calls.
    static let LogTag = "[SwiftyDropbox]"

    static func log(
        _ level: LogLevel = .info,
        _ message: String
    ) {
        DropboxClientsManager.loggingClosure?(level, "\(LogTag) \(message)")
    }

    static func logBackgroundSession(
        _ message: String
    ) {
        logBackgroundSession(backgroundSessionLogLevel, message)
    }

    /// For logging something background-session related at a different level than backgroundSessionLogLevel, such as .error.
    static func logBackgroundSession(
        _ level: LogLevel,
        _ message: String
    ) {
        log(backgroundSessionLogLevel, "bg session - \(message)")
    }
}

// MARK: Locking
/// Wrapper around a value with a lock
///
/// Copied from https://github.com/home-assistant/HAKit/blob/main/Source/Internal/HAProtected.swift
public class UnfairLock<ValueType> {
    private var value: ValueType
    private let lock: os_unfair_lock_t = {
        let value = os_unfair_lock_t.allocate(capacity: 1)
        value.initialize(to: os_unfair_lock())
        return value
    }()

    /// Create a new protected value
    /// - Parameter value: The initial value
    public init(value: ValueType) {
        self.value = value
    }

    deinit {
        lock.deinitialize(count: 1)
        lock.deallocate()
    }

    /// Get and optionally change the value
    /// - Parameter handler: Will be invoked immediately with the current value as an inout parameter.
    /// - Returns: The value returned by the handler block
    @discardableResult
    public func mutate<HandlerType>(using handler: (inout ValueType) -> HandlerType) -> HandlerType {
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        return handler(&value)
    }

    /// Read the value and get a result out of it
    /// - Parameter handler: Will be invoked immediately with the current value.
    /// - Returns: The value returned by the handler block
    public func read<T>(_ handler: (ValueType) -> T) -> T {
        os_unfair_lock_lock(lock)
        defer { os_unfair_lock_unlock(lock) }
        return handler(value)
    }
}
