///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

enum ReconnectionHelpers: ReconnectionHelpersShared {
    static func rebuildRequest(apiRequest: ApiRequest, client: DropboxTransportClientInternal) throws -> DropboxBaseRequestBox {
        let info = try persistedRequestInfo(from: apiRequest)

        switch info.routeName {
        case "files_alpha/upload":
            return .filesalphaUpload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.alphaUpload,
                    client: client
                )
            )
        case "files_download":
            return .filesdownload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.download,
                    client: client
                )
            )
        case "files_download_zip":
            return .filesdownloadZip(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.downloadZip,
                    client: client
                )
            )
        case "files_export":
            return .filesexport(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.export,
                    client: client
                )
            )
        case "files_get_preview":
            return .filesgetPreview(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getPreview,
                    client: client
                )
            )
        case "files_get_thumbnail":
            return .filesgetThumbnail(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getThumbnail,
                    client: client
                )
            )
        case "files_get_thumbnail_v2":
            return .filesgetThumbnailV2(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getThumbnailV2,
                    client: client
                )
            )
        case "files_paper/create":
            return .filespaperCreate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.paperCreate,
                    client: client
                )
            )
        case "files_paper/update":
            return .filespaperUpdate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.paperUpdate,
                    client: client
                )
            )
        case "files_upload":
            return .filesupload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.upload,
                    client: client
                )
            )
        case "files_upload_session/append_v2":
            return .filesuploadSessionAppendV2(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionAppendV2,
                    client: client
                )
            )
        case "files_upload_session/append":
            return .filesuploadSessionAppend(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionAppend,
                    client: client
                )
            )
        case "files_upload_session/finish":
            return .filesuploadSessionFinish(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionFinish,
                    client: client
                )
            )
        case "files_upload_session/start":
            return .filesuploadSessionStart(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionStart,
                    client: client
                )
            )
        case "paper_docs/create":
            return .paperdocsCreate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsCreate,
                    client: client
                )
            )
        case "paper_docs/download":
            return .paperdocsDownload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsDownload,
                    client: client
                )
            )
        case "paper_docs/update":
            return .paperdocsUpdate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsUpdate,
                    client: client
                )
            )
        case "sharing_get_shared_link_file":
            return .sharinggetSharedLinkFile(
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
