///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

// The case string below must match those created by ReconnectionHelpers+Handwritten.swift using
// the route name and namespace as formatted for the generated `Route` object in SwiftTypes.jinja
// Format: "<namespace>/<route_name>" e.g., "files/upload_session/append_v2" for Files.uploadSessionAppendV2
enum AppAuthReconnectionHelpers: ReconnectionHelpersShared {
    static func rebuildRequest(apiRequest: ApiRequest, client: DropboxTransportClientInternal) throws -> DropboxAppBaseRequestBox {
        let info = try persistedRequestInfo(from: apiRequest)

        switch info.namespaceRouteName {
        case "files/get_thumbnail_v2":
            return .files_getThumbnailV2(
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
