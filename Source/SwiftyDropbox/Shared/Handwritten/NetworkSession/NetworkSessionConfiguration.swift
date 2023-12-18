///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

public struct NetworkSessionConfiguration {
    public enum Kind {
        case `default`
        case ephemeral
        case background(String)
    }

    public var identifier: String? {
        switch kind {
        case .default, .ephemeral:
            return nil
        case .background(let identifier):
            return identifier
        }
    }

    public var timeoutIntervalForRequest: Double {
        get {
            urlSessionConfiguration.timeoutIntervalForRequest
        }
        set {
            urlSessionConfiguration.timeoutIntervalForRequest = newValue
        }
    }

    public var timeoutIntervalForResource: Double {
        get {
            urlSessionConfiguration.timeoutIntervalForResource
        }
        set {
            urlSessionConfiguration.timeoutIntervalForResource = newValue
        }
    }

    public var allowsCellularAccess: Bool {
        get {
            urlSessionConfiguration.allowsCellularAccess
        }
        set {
            urlSessionConfiguration.allowsCellularAccess = newValue
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    public var allowsExpensiveNetworkAccess: Bool {
        get {
            urlSessionConfiguration.allowsExpensiveNetworkAccess
        }
        set {
            urlSessionConfiguration.allowsExpensiveNetworkAccess = newValue
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    public var allowsConstrainedNetworkAccess: Bool {
        get {
            urlSessionConfiguration.allowsConstrainedNetworkAccess
        }
        set {
            urlSessionConfiguration.allowsConstrainedNetworkAccess = newValue
        }
    }

    public var sharedContainerIdentifier: String? {
        get {
            urlSessionConfiguration.sharedContainerIdentifier
        }
        set {
            urlSessionConfiguration.sharedContainerIdentifier = newValue
        }
    }

    public var httpMaximumConnectionsPerHost: Int {
        get {
            urlSessionConfiguration.httpMaximumConnectionsPerHost
        }
        set {
            urlSessionConfiguration.httpMaximumConnectionsPerHost = newValue
        }
    }

    public var isDiscretionary: Bool {
        get {
            urlSessionConfiguration.isDiscretionary
        }
        set {
            urlSessionConfiguration.isDiscretionary = newValue
        }
    }

    public var urlCache: URLCache? {
        get {
            urlSessionConfiguration.urlCache
        }
        set {
            urlSessionConfiguration.urlCache = newValue
        }
    }

    public let kind: Kind

    internal var urlSessionConfiguration: URLSessionConfiguration

    public init(kind: Kind) {
        self.kind = kind
        switch kind {
        case .default:
            self.urlSessionConfiguration = .default
        case .ephemeral:
            self.urlSessionConfiguration = .ephemeral
        case .background(let identifier):
            self.urlSessionConfiguration = .background(withIdentifier: identifier)
        }
    }

    public static var `default`: Self = {
        var instance = Self(kind: .default)
        instance.timeoutIntervalForRequest = 100
        return instance
    }()

    public static var defaultLongpoll: Self = {
        var instance = Self(kind: .default)
        instance.timeoutIntervalForRequest = 480
        return instance
    }()

    public static func background(withIdentifier identifier: String, sharedContainerIdentifier: String? = nil) -> Self {
        var configuration = Self(kind: .background(identifier))
        configuration.sharedContainerIdentifier = sharedContainerIdentifier
        return configuration
    }
}
