///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

import Foundation

/// Allows for heterogenous collections of typed requests
public enum DropboxAppBaseRequestBox {
    case getThumbnailV2(DownloadRequestFile<Files.PreviewResultSerializer, Files.ThumbnailV2ErrorSerializer>)
}