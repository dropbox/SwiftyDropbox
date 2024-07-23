///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

enum ReconnectionHelpers: ReconnectionHelpersShared {
    static func rebuildRequest(apiRequest: ApiRequest, client: DropboxTransportClientInternal) throws -> DropboxBaseRequestBox {
        let info = try persistedRequestInfo(from: apiRequest)

        switch info.routeName {
        case "alpha/upload":
            return .alphaUpload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.alphaUpload,
                    client: client
                )
            )
        case "download":
            return .download(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.download,
                    client: client
                )
            )
        case "download_zip":
            return .downloadZip(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.downloadZip,
                    client: client
                )
            )
        case "export":
            return .export(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.export,
                    client: client
                )
            )
        case "get_preview":
            return .getPreview(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getPreview,
                    client: client
                )
            )
        case "get_thumbnail":
            return .getThumbnail(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getThumbnail,
                    client: client
                )
            )
        case "get_thumbnail_v2":
            return .getThumbnailV2(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getThumbnailV2,
                    client: client
                )
            )
        case "paper/create":
            return .paperCreate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.paperCreate,
                    client: client
                )
            )
        case "paper/update":
            return .paperUpdate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.paperUpdate,
                    client: client
                )
            )
        case "upload":
            return .upload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.upload,
                    client: client
                )
            )
        case "upload_session/append_v2":
            return .uploadSessionAppendV2(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionAppendV2,
                    client: client
                )
            )
        case "upload_session/append":
            return .uploadSessionAppend(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionAppend,
                    client: client
                )
            )
        case "upload_session/finish":
            return .uploadSessionFinish(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionFinish,
                    client: client
                )
            )
        case "upload_session/start":
            return .uploadSessionStart(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionStart,
                    client: client
                )
            )
        case "docs/create":
            return .docsCreate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsCreate,
                    client: client
                )
            )
        case "docs/download":
            return .docsDownload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsDownload,
                    client: client
                )
            )
        case "docs/update":
            return .docsUpdate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsUpdate,
                    client: client
                )
            )
        case "get_shared_link_file":
            return .getSharedLinkFile(
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
