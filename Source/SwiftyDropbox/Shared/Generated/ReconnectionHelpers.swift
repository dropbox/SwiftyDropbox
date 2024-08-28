///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

// The case string below must match those created by ReconnectionHelpers+Handwritten.swift using
// the route name and namespace as formatted for the generated `Route` object in SwiftTypes.jinja
// Format: "<namespace>/<route_name>" e.g., "files/upload_session/append_v2" for Files.uploadSessionAppendV2
enum ReconnectionHelpers: ReconnectionHelpersShared {
    static func rebuildRequest(apiRequest: ApiRequest, client: DropboxTransportClientInternal) throws -> DropboxBaseRequestBox {
        let info = try persistedRequestInfo(from: apiRequest)

        switch info.namespaceRouteName {
        case "files/alpha/upload":
            return .files_alphaUpload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.alphaUpload,
                    client: client
                )
            )
        case "files/download":
            return .files_download(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.download,
                    client: client
                )
            )
        case "files/download_zip":
            return .files_downloadZip(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.downloadZip,
                    client: client
                )
            )
        case "files/export":
            return .files_export(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.export,
                    client: client
                )
            )
        case "files/get_preview":
            return .files_getPreview(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getPreview,
                    client: client
                )
            )
        case "files/get_thumbnail":
            return .files_getThumbnail(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getThumbnail,
                    client: client
                )
            )
        case "files/get_thumbnail_v2":
            return .files_getThumbnailV2(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getThumbnailV2,
                    client: client
                )
            )
        case "files/paper/create":
            return .files_paperCreate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.paperCreate,
                    client: client
                )
            )
        case "files/paper/update":
            return .files_paperUpdate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.paperUpdate,
                    client: client
                )
            )
        case "files/upload":
            return .files_upload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.upload,
                    client: client
                )
            )
        case "files/upload_session/append":
            return .files_uploadSessionAppend(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionAppend,
                    client: client
                )
            )
        case "files/upload_session/append_v2":
            return .files_uploadSessionAppendV2(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionAppendV2,
                    client: client
                )
            )
        case "files/upload_session/finish":
            return .files_uploadSessionFinish(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionFinish,
                    client: client
                )
            )
        case "files/upload_session/start":
            return .files_uploadSessionStart(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionStart,
                    client: client
                )
            )
        case "paper/docs/create":
            return .paper_docsCreate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsCreate,
                    client: client
                )
            )
        case "paper/docs/download":
            return .paper_docsDownload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsDownload,
                    client: client
                )
            )
        case "paper/docs/update":
            return .paper_docsUpdate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsUpdate,
                    client: client
                )
            )
        case "sharing/get_shared_link_file":
            return .sharing_getSharedLinkFile(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Sharing.getSharedLinkFile,
                    client: client
                )
            )
        default:
            throw ReconnectionErrorKind.missingReconnectionCase
        }
    }
}
