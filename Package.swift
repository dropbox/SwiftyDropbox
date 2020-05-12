// swift-tools-version:5.1
///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import PackageDescription

let package = Package(
    name: "SwiftyDropbox",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "SwiftyDropbox",
            targets: ["SwiftyDropbox"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMinor(from: "4.8.2")),
    ],
    targets: [
       .target(
           name: "SwiftyDropboxObjC",
           dependencies: [],
           path: "Source/SwiftyDropbox/ObjectiveC"
        ),
        .target(
            name: "SwiftyDropbox",
            dependencies: [
                .byName(name: "Alamofire"),
                .target(name: "SwiftyDropboxObjC"),
            ],
            path: "Source/SwiftyDropbox/Swift"
        )
    ],
    swiftLanguageVersions: [.v4_2]
)
