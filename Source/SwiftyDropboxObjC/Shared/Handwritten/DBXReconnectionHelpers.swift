///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

extension ReconnectionError {
    var objc: DBXReconnectionHelperError {
        DBXReconnectionHelperError(swift: self)
    }
}

@objc
public class DBXReconnectionHelperError: NSObject {
    let swift: ReconnectionError

    @objc
    public var errorMessage: String { swift.reconnectionErrorKind.rawValue }

    @objc
    public var taskDescription: String? { swift.taskDescription }

    init(swift: ReconnectionError) {
        self.swift = swift
    }
}

@objc
public class DBXReconnectionResult: NSObject {
    @objc
    public let request: DBXRequest?
    @objc
    public let error: DBXReconnectionHelperError?

    init(request: DBXRequest?, error: DBXReconnectionHelperError?) {
        self.request = request
        self.error = error
    }
}

@objc
public class DBXDefaultBackgroundExtensionSessionCreationInfo: NSObject {
    let swift: DefaultBackgroundExtensionSessionCreationInfo

    public init(swift: DefaultBackgroundExtensionSessionCreationInfo) {
        self.swift = swift
    }

    @objc
    public init(backgroundSessionIdentifier: String, sharedContainerIdentifier: String) {
        self.swift = DefaultBackgroundExtensionSessionCreationInfo(
            backgroundSessionIdentifier: backgroundSessionIdentifier,
            sharedContainerIdentifier: sharedContainerIdentifier
        )
    }
}

@objc
public class DBXCustomBackgroundExtensionSessionCreationInfo: NSObject {
    let swift: CustomBackgroundExtensionSessionCreationInfo

    @objc
    public init(backgroundTransportClient: DBXDropboxTransportClient) {
        self.swift = .init(backgroundTransportClient: backgroundTransportClient.swift)
    }

    @objc
    public init(backgroundSessionConfiguration: DBXNetworkSessionConfiguration) {
        self.swift = .init(backgroundSessionConfiguration: backgroundSessionConfiguration.swift)
    }

    init(swift: CustomBackgroundExtensionSessionCreationInfo) {
        self.swift = swift
    }
}

@objc
public class DBXBackgroundExtensionSessionCreationInfo: NSObject {
    let swift: BackgroundExtensionSessionCreationInfo

    @objc
    public init(defaultInfo: DBXDefaultBackgroundExtensionSessionCreationInfo) {
        self.swift = .init(defaultInfo: defaultInfo.swift)
    }

    @objc
    public init(customInfo: DBXCustomBackgroundExtensionSessionCreationInfo) {
        self.swift = .init(customInfo: customInfo.swift)
    }

    init(swift: BackgroundExtensionSessionCreationInfo) {
        self.swift = swift
    }
}
