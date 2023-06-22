///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

extension NetworkSessionConfiguration {
    var objc: DBXNetworkSessionConfiguration {
        DBXNetworkSessionConfiguration(swift: self)
    }
}

public class DBXNetworkSessionConfiguration: NSObject {
    var swift: NetworkSessionConfiguration

    fileprivate init(swift: NetworkSessionConfiguration) {
        self.swift = swift
    }

    @objc
    public var timeoutIntervalForRequest: Double {
        get {
            swift.timeoutIntervalForRequest
        }
        set {
            swift.timeoutIntervalForRequest = newValue
        }
    }

    @objc
    public var timeoutIntervalForResource: Double {
        get {
            swift.timeoutIntervalForResource
        }
        set {
            swift.timeoutIntervalForResource = newValue
        }
    }

    @objc
    public var allowsCellularAccess: Bool {
        get {
            swift.allowsCellularAccess
        }
        set {
            swift.allowsCellularAccess = newValue
        }
    }

    @objc
    @available(iOS 13.0, macOS 10.15, *)
    public var allowsExpensiveNetworkAccess: Bool {
        get {
            swift.allowsExpensiveNetworkAccess
        }
        set {
            swift.allowsExpensiveNetworkAccess = newValue
        }
    }

    @objc
    @available(iOS 13.0, macOS 10.15, *)
    public var allowsConstrainedNetworkAccess: Bool {
        get {
            swift.allowsConstrainedNetworkAccess
        }
        set {
            swift.allowsConstrainedNetworkAccess = newValue
        }
    }

    @objc
    public var sharedContainerIdentifier: String? {
        get {
            swift.sharedContainerIdentifier
        }
        set {
            swift.sharedContainerIdentifier = newValue
        }
    }

    @objc
    public var httpMaximumConnectionsPerHost: Int {
        get {
            swift.httpMaximumConnectionsPerHost
        }
        set {
            swift.httpMaximumConnectionsPerHost = newValue
        }
    }

    @objc
    public static var `default` = DBXNetworkSessionConfiguration(swift: NetworkSessionConfiguration.default)
    @objc
    public static var defaultLongpoll = DBXNetworkSessionConfiguration(swift: NetworkSessionConfiguration.defaultLongpoll)
    @objc
    public static func background(withIdentifier identifier: String) -> DBXNetworkSessionConfiguration {
        DBXNetworkSessionConfiguration(swift: NetworkSessionConfiguration(kind: .background(identifier)))
    }

    @objc
    public static func background(withIdentifier identifier: String, sharedContainerIdentifier: String) -> DBXNetworkSessionConfiguration {
        DBXNetworkSessionConfiguration(
            swift: NetworkSessionConfiguration
                .background(withIdentifier: identifier, sharedContainerIdentifier: sharedContainerIdentifier)
        )
    }
}
