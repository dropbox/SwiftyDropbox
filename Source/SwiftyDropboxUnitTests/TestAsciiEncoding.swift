///
/// Copyright (c) 2023 Dropbox, Inc. All rights reserved.
///

import Foundation

@testable import SwiftyDropbox
import XCTest

final class TestAsciiEncoding: XCTestCase {
    let stringsToEncodedStrings = [
        "héllø wörld": "h\\u00e9ll\\u00f8 w\\u00f6rld",
        "hello": "hello",
        "": "",
        "こんにちは": "\\u3053\\u3093\\u306b\\u3061\\u306f",
        "this has a clustered flag 🇺🇸": "this has a clustered flag \\ud83c\\uddfa\\ud83c\\uddf8",
        "this is a big emoji 👩‍👩‍👧‍👦": "this is a big emoji \\ud83d\\udc69\\u200d\\ud83d\\udc69\\u200d\\ud83d\\udc67\\u200d\\ud83d\\udc66",
        "🍺": "\\ud83c\\udf7a",
        "this\nhas some whitespace": "this\nhas some whitespace",
    ]

    func testEncodings() {
        for (key, value) in stringsToEncodedStrings {
            let lhs = Utilities.asciiEscape(key)
            let rhs = value
            XCTAssertEqual(lhs, rhs)
        }
    }
}
