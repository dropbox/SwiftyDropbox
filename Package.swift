// swift-tools-version:5.1
///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import PackageDescription

let package = Package(
    name: "SwiftyDropbox",
    platforms: [
        // The files in Source/SwiftyDropbox/Platform have conditional compilation for the iOS and macOS platforms to make this work. Perhaps Swift 5.3 can make this unnecessary: https://stackoverflow.com/questions/61730642
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
