///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

@objc
public protocol DBXRequest {
    var clientPersistedString: String? { get }

    @available(iOS 13.0, macOS 10.13, *)
    var earliestBeginDate: Date? { get }

    @discardableResult
    func persistingString(string: String?) -> Self

    @available(iOS 13.0, macOS 10.13, *)
    @discardableResult
    func settingEarliestBeginDate(date: Date?) -> Self

    func cancel()
}
