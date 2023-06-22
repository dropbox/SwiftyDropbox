//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

protocol ApiRequestBox {
    var value: ApiRequest? { get }
    init(value: ApiRequest)
}

class WeakApiRequestBox: ApiRequestBox {
    weak var value: ApiRequest?
    required init(value: ApiRequest) {
        self.value = value
    }
}

class PendingReconnectionStrongApiRequestBox: ApiRequestBox {
    var value: ApiRequest? {
        strongValue
    }

    var strongValue: ApiRequest
    required init(value: ApiRequest) {
        self.strongValue = value
    }
}

protocol RequestMap {
    func set(request: ApiRequest, taskIdentifier: Int)
    func setPendingReconnection(request: ApiRequest, taskIdentifier: Int)
    func getRequest(taskIdentifier: Int) -> ApiRequest?
    func getAllRequests() -> [ApiRequest]
    func getAllPendingReconnectionRequests() -> [ApiRequest]
    func weakifyReferencesToReconnectedRequests()
    func removeRequest(taskIdentifier: Int)
    func removeAllRequests()
}

class RequestMapImpl: RequestMap {
    private var map: [Int: ApiRequestBox] = [:]
    private var cleanupThreshold: Int = 250

    init() {}

    func setPendingReconnection(request: ApiRequest, taskIdentifier: Int) {
        map[taskIdentifier] = PendingReconnectionStrongApiRequestBox(value: request)
    }

    func set(request: ApiRequest, taskIdentifier: Int) {
        map[taskIdentifier] = WeakApiRequestBox(value: request)

        if map.count >= cleanupThreshold {
            cleanupEmptyBoxes()
        }
    }

    func getRequest(taskIdentifier: Int) -> ApiRequest? {
        map[taskIdentifier]?.value
    }

    func getAllRequests() -> [ApiRequest] {
        Array(map.values.compactMap(\.value))
    }

    func getAllPendingReconnectionRequests() -> [ApiRequest] {
        let isPending: (ApiRequestBox) -> Bool = { $0 is PendingReconnectionStrongApiRequestBox }
        return Array(map.values.filter(isPending).compactMap(\.value))
    }

    func weakifyReferencesToReconnectedRequests() {
        map = map.mapValues { box in
            if let box = box as? PendingReconnectionStrongApiRequestBox {
                return WeakApiRequestBox(value: box.strongValue)
            }
            return box
        }
    }

    func cleanupEmptyBoxes() {
        map = map.filter { _, box in
            if let box = box as? WeakApiRequestBox, box.value == nil {
                return false
            }
            return true
        }
    }

    func removeRequest(taskIdentifier: Int) {
        map[taskIdentifier] = nil
    }

    func removeAllRequests() {
        map = [:]
    }

    func __test_only_setCleanupThreshold(value: Int) {
        cleanupThreshold = value
    }

    var __test_only_map: [Int: ApiRequestBox] {
        map
    }
}
