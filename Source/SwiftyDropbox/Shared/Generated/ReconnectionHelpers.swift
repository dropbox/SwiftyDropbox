///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation

enum ReconnectionHelpers: ReconnectionHelpersShared {
    static func rebuildRequest(apiRequest: ApiRequest, client: DropboxTransportClientInternal) throws -> DropboxBaseRequestBox {
        let info = try persistedRequestInfo(from: apiRequest)

        switch info.routeName {
        case "alphaUpload":
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
        case "downloadZip":
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
        case "getPreview":
            return .getPreview(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getPreview,
                    client: client
                )
            )
        case "getThumbnail":
            return .getThumbnail(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getThumbnail,
                    client: client
                )
            )
        case "getThumbnailV2":
            return .getThumbnailV2(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.getThumbnailV2,
                    client: client
                )
            )
        case "paperCreate":
            return .paperCreate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.paperCreate,
                    client: client
                )
            )
        case "paperUpdate":
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
        case "uploadSessionAppendV2":
            return .uploadSessionAppendV2(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionAppendV2,
                    client: client
                )
            )
        case "uploadSessionAppend":
            return .uploadSessionAppend(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionAppend,
                    client: client
                )
            )
        case "uploadSessionFinish":
            return .uploadSessionFinish(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionFinish,
                    client: client
                )
            )
        case "uploadSessionStart":
            return .uploadSessionStart(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Files.uploadSessionStart,
                    client: client
                )
            )
        case "docsCreate":
            return .docsCreate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsCreate,
                    client: client
                )
            )
        case "docsDownload":
            return .docsDownload(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsDownload,
                    client: client
                )
            )
        case "docsUpdate":
            return .docsUpdate(
                rebuildRequest(
                    apiRequest: apiRequest,
                    info: info,
                    route: Paper.docsUpdate,
                    client: client
                )
            )
        case "getSharedLinkFile":
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
