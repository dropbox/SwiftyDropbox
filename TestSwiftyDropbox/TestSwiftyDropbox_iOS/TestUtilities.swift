///
/// Copyright (c) 2023 Dropbox, Inc. All rights reserved.
///

import Foundation

public enum TestConstants {
    public static var sharedContainerDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: TestData.sharedContainerIdentifier)!
    public static var cachesDirectory = sharedContainerDirectory.appendingPathComponent("Caches")
    public static var fileToUpload = cachesDirectory.appendingPathComponent("file.txt")
    public static var dropboxTestFolder = "/background_session_testing"
    public static var localDownloadFolder = cachesDirectory.appendingPathComponent("downloads")
}

public class TestUtilities {
    public static func createFileToUpload(sizeInKBs: Double) {
        let sizeInBytes = Int(1_024 * sizeInKBs)
        writeFile(ofSize: sizeInBytes, at: TestConstants.fileToUpload)
    }

    public static func writeFile(ofSize size: Int, at url: URL) {
        let content = "test_content"
        let contentData = content.data(using: .utf8)!
        let dataSize = contentData.count

        do {
            let repeatCount = size / dataSize
            let fileContent = String(repeating: content, count: repeatCount)

            try fileContent.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing file: \(error)")
        }
    }

    public static func summary(of route: String, from response: CustomStringConvertible?, error: CustomStringConvertible?) -> String {
        "\(route) response: \(response?.description ?? "nil") error: \(error?.description ?? "nil")"
    }
}
