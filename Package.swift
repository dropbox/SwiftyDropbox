///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import PackageDescription

let package = Package(
    name: "SwiftyDropbox",
    dependencies: [
        .Package(url: "https://github.com/Alamofire/Alamofire.git", Version(4,0,0)),
    ]
)
