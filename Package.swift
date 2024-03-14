// swift-tools-version:5.6
///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import PackageDescription

let package = Package(
    name: "SwiftyDropbox",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
    ],
    products: [
        .library(name: "SwiftyDropbox", targets: ["SwiftyDropbox"]),
        .library(name: "SwiftyDropboxObjC", targets: ["SwiftyDropboxObjC"]),
    ],
    targets: [
        .target(
            name: "SwiftyDropbox",
            path: "Source/SwiftyDropbox",
            resources: [.process("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "SwiftyDropboxObjC",
            dependencies: ["SwiftyDropbox"],
            path: "Source/SwiftyDropboxObjC",
            resources: [.process("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "SwiftyDropboxUnitTests",
            dependencies: ["SwiftyDropbox"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
