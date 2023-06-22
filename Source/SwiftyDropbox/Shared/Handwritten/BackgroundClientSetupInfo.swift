///
/// Copyright (c) 2023 Dropbox, Inc. All rights reserved.
///

import Foundation

public class DefaultBackgroundExtensionSessionCreationInfo {
    let backgroundSessionIdentifier: String
    let sharedContainerIdentifier: String

    public init(backgroundSessionIdentifier: String, sharedContainerIdentifier: String) {
        self.backgroundSessionIdentifier = backgroundSessionIdentifier
        self.sharedContainerIdentifier = sharedContainerIdentifier
    }
}

public class CustomBackgroundExtensionSessionCreationInfo {
    let backgroundTransportClient: DropboxTransportClient?
    let backgroundSessionConfiguration: NetworkSessionConfiguration?

    var backgroundSessionIdentifier: String? {
        if let backgroundTransportClient = backgroundTransportClient {
            return backgroundTransportClient.identifier
        } else {
            return backgroundSessionConfiguration?.identifier
        }
    }

    public init(backgroundTransportClient: DropboxTransportClient?) {
        self.backgroundTransportClient = backgroundTransportClient
        self.backgroundSessionConfiguration = nil
    }

    public init(backgroundSessionConfiguration: NetworkSessionConfiguration?) {
        self.backgroundTransportClient = nil
        self.backgroundSessionConfiguration = backgroundSessionConfiguration
    }
}

public class BackgroundExtensionSessionCreationInfo {
    let defaultInfo: DefaultBackgroundExtensionSessionCreationInfo?
    let customInfo: CustomBackgroundExtensionSessionCreationInfo?

    var identifier: String? {
        if let defaultInfo = defaultInfo {
            return defaultInfo.backgroundSessionIdentifier
        } else {
            return customInfo?.backgroundSessionIdentifier
        }
    }

    public init(defaultInfo: DefaultBackgroundExtensionSessionCreationInfo) {
        self.defaultInfo = defaultInfo
        self.customInfo = nil
    }

    public init(customInfo: CustomBackgroundExtensionSessionCreationInfo) {
        self.defaultInfo = nil
        self.customInfo = customInfo
    }
}
