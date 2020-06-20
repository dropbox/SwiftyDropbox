// swift-tools-version:5.1
///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import PackageDescription

let package = Package(
    name: "SwiftyDropbox",
	platforms: [.iOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMinor(from: "4.8.2")),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftyDropbox",
            targets: ["SwiftyDropbox"]),
	],
	targets: [
		.target(name: "SwiftyDropbox", dependencies: ["AlamoFire"])
	]
)
