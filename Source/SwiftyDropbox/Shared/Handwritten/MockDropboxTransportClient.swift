///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation

class MockDropboxTransportClient: DropboxTransportClient {
    var identifier: String?
    let filesAccess: FilesAccess = FilesAccessImpl()

    var selectUser: String?
    var pathRoot: Common.PathRoot?
    var didFinishBackgroundEvents: (() -> Void)?
    var accessTokenProvider: AccessTokenProvider? = LongLivedAccessTokenProvider(accessToken: "accessToken")
    var isBackgroundClient: Bool = false

    init() {}

    // MARK: Request Mocking

    fileprivate var allRequests = Requests()

    private func createRegisteredApiRequest<ASerial, RSerial, ESerial>(
        for route: Route<ASerial, RSerial, ESerial>
    ) -> ApiRequest {
        let apiRequest = MockApiRequest(requestUrl: DropboxTransportClientImpl.url(for: route))

        allRequests.record(request: apiRequest, with: route.name)

        return apiRequest
    }

    func getLastRequest() -> ApiRequest? {
        allRequests.getLastRequest()
    }

    func getRequest(with tag: String) -> ApiRequest? {
        allRequests.getRequest(with: tag)
    }

    // MARK: DropboxTransportClient

    func request<ASerial, RSerial, ESerial>(_ route: Route<ASerial, RSerial, ESerial>) -> RpcRequest<RSerial, ESerial> where ASerial: JSONSerializer,
        RSerial: JSONSerializer, ESerial: JSONSerializer {
        request(route, serverArgs: nil)
    }

    func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>, serverArgs: ASerial.ValueType? = nil
    ) -> RpcRequest<RSerial, ESerial> {
        let apiRequest = createRegisteredApiRequest(for: route)

        return RpcRequest(
            request: apiRequest,
            responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer
        )
    }

    func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>, serverArgs: ASerial.ValueType, input: UploadBody
    ) -> UploadRequest<RSerial, ESerial> {
        let apiRequest = createRegisteredApiRequest(for: route)
        return UploadRequest(
            request: apiRequest,
            responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer
        )
    }

    func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType,
        overwrite: Bool,
        destination: URL
    ) -> DownloadRequestFile<RSerial, ESerial> {
        let apiRequest = createRegisteredApiRequest(for: route)

        return DownloadRequestFile(
            request: apiRequest,
            responseSerializer: route.responseSerializer,
            errorSerializer: route.errorSerializer,
            moveToDestination: { [weak self] temporaryLocation in
                try (self.orThrow()).filesAccess.moveFile(
                    from: temporaryLocation,
                    to: destination,
                    overwrite: overwrite
                )
            }, errorDataFromLocation: { [weak self] url in
                try self?.filesAccess.errorData(from: url)
            }
        )
    }

    func request<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        serverArgs: ASerial.ValueType
    ) -> DownloadRequestMemory<RSerial, ESerial> {
        let apiRequest = createRegisteredApiRequest(for: route)

        return DownloadRequestMemory(
            request: apiRequest, responseSerializer: route.responseSerializer, errorSerializer: route.errorSerializer
        )
    }

    func reconnectRequest<ASerial, RSerial, ESerial>(_ route: Route<ASerial, RSerial, ESerial>, apiRequest: ApiRequest) -> UploadRequest<RSerial, ESerial>
        where ASerial: JSONSerializer, RSerial: JSONSerializer, ESerial: JSONSerializer {
        fatalError("unimplemented")
    }

    func reconnectRequest<ASerial, RSerial, ESerial>(
        _ route: Route<ASerial, RSerial, ESerial>,
        apiRequest: ApiRequest,
        overwrite: Bool,
        destination: URL
    ) -> DownloadRequestFile<RSerial, ESerial> where ASerial: JSONSerializer, RSerial: JSONSerializer, ESerial: JSONSerializer {
        fatalError("unimplemented")
    }

    func shutdown() {}
}

private class Requests {
    var allRequests: [(String, ApiRequest)] = []

    func getLastRequest() -> ApiRequest? {
        allRequests.last?.1
    }

    func getRequest(with tag: String) -> ApiRequest? {
        let tagsAreEqual: (String, ApiRequest) -> Bool = { requestTag, _ in requestTag == tag }
        return allRequests.last(where: tagsAreEqual)?.1
    }

    func record(request: ApiRequest, with tag: String) {
        allRequests.append((tag, request))
    }
}
