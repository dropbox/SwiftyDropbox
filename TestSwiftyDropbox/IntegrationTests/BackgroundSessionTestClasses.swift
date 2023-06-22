///
/// Copyright (c) 2022 Dropbox, Inc. All rights reserved.
///

import Foundation
import SwiftyDropbox

enum BackgroundTestLogger {
    static var cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    static var logsFileURL = cachesDirectory.appendingPathComponent("app_logs.txt")

    static func log(_ message: String) {
        NSLog(message)
        appendToFile(fileURL: logsFileURL, content: message)
    }

    static func appendToFile(fileURL: URL, content c: String) {
        let content = c + "\n"
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                if let data = content.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Error: Unable to append content to the file. \(error.localizedDescription)")
        }
    }
}
