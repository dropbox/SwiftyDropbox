///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

enum AppAuthReconnectionHelpers: ReconnectionHelpersShared {
    static func rebuildRequest(apiRequest: ApiRequest, client: DropboxTransportClientInternal) throws -> DropboxAppBaseRequestBox {
        let info = try persistedRequestInfo(from: apiRequest)

        switch info.routeName {
        case "getThumbnailV2":
            return .getThumbnailV2(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getThumbnailV2,
                    client: client
                )
            )
        default:
            throw ReconnectionErrorKind.missingReconnectionCase
        }
    }
}
