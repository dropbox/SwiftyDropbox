///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation

public class BatchUploadTask {
    let uploadData: BatchUploadData

    init(uploadData: BatchUploadData) {
        self.uploadData = uploadData
    }

    public func cancel() {
        uploadData.cancel = true
        uploadData.startRequests.values.forEach { $0.cancel() }
        uploadData.appendRequests.values.forEach { $0.cancel() }
        uploadData.finishRequest?.cancel()
    }
}
