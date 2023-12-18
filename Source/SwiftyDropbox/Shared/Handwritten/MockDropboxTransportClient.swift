///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation

protocol DropboxTransportClientOwning {
    var client: DropboxTransportClient { get }
    init(client: DropboxTransportClient)
}

protocol JSONRepresentable {
    func json() throws -> JSON
}

enum MockingUtilities {
    static func makeMock<T: DropboxTransportClientOwning>(forType: T.Type) -> (T, MockDropboxTransportClient) {
        let mockTransportClient = MockDropboxTransportClient()
        let namespaceObject = T(client: mockTransportClient)
        return (namespaceObject, mockTransportClient)
    }

    static func jsonObject<T: JSONRepresentable>(from result: T) throws -> [String: Any] {
        let json = try result.json()
        let jsonObject = try (SerializeUtil.prepareJSONForSerialization(json) as? [String: Any]).orThrow()
        return jsonObject
    }
}

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
    typealias MockRequestHandler = (MockApiRequest) -> Void
    /// This is called whenever a mock API request is created. By default it will do nothing, but you may be interested in  `MockDropboxTransportClient.alwaysFailMockRequestHandler` to always fail requests
    var mockRequestHandler: MockRequestHandler = noopMockRequestHandler
    /// No-op: Does nothing additional to the request
    static let noopMockRequestHandler: MockRequestHandler = { _ in }
    /// Always fails the request with `MockError.intentionalFailure`
    static let alwaysFailMockRequestHandler: MockRequestHandler = {
        enum MockError: Error {
            case intentionalFailure
        }
        try? $0.handleMockInput(.clientError(error: .other(MockError.intentionalFailure)))
    }

    private func createRegisteredApiRequest<ASerial, RSerial, ESerial>(
        for route: Route<ASerial, RSerial, ESerial>
    ) -> MockApiRequest {
        let apiRequest = MockApiRequest(requestUrl: DropboxTransportClientImpl.url(for: route))

        mockRequestHandler(apiRequest)

        allRequests.record(request: apiRequest, with: route.name)

        return apiRequest
    }

    func getLastRequest() -> MockApiRequest? {
        allRequests.getLastRequest()
    }

    func getRequest(with tag: String) -> MockApiRequest? {
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
    var allRequests: [(String, MockApiRequest)] = []

    func getLastRequest() -> MockApiRequest? {
        allRequests.last?.1
    }

    func getRequest(with tag: String) -> MockApiRequest? {
        let tagsAreEqual: (String, ApiRequest) -> Bool = { requestTag, _ in requestTag == tag }
        return allRequests.last(where: tagsAreEqual)?.1
    }

    func record(request: MockApiRequest, with tag: String) {
        allRequests.append((tag, request))
    }
}
