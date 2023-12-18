//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation

public enum FilesAccessError: Error {
    case errorMovingToTempLocation(Error)
    case errorMovingFromTempLocation(Error)
    case errorMovingFromTempLocationDestinationCollision(String)
    case couldNotReadErrorDataAtUrl(Error)
}

@objc(DBFilesAccess)
public protocol FilesAccess {
    func moveFileToTemporaryLocation(from networkSessionTemporaryLocation: URL) throws -> URL
    func moveFile(from temporaryLocation: URL, to finalUrl: URL, overwrite: Bool) throws -> URL
    func errorData(from location: URL) throws -> Data
}

public class FilesAccessImpl: FilesAccess {
    var fileManager: FileManagerProtocol
    let tempFolder = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

    public convenience init() {
        self.init(fileManager: FileManager.default)
    }

    init(fileManager: FileManagerProtocol) {
        self.fileManager = fileManager
        setupDirectories()
    }

    private func setupDirectories() {
        if !fileManager.fileExists(atPath: tempFolder.path) {
            try! fileManager.createDirectory(at: tempFolder, withIntermediateDirectories: true, attributes: nil)
        }
    }

    public func moveFileToTemporaryLocation(from networkSessionTemporaryLocation: URL) throws -> URL {
        do {
            let tempOutputURL = tempFolder.appendingPathComponent(UUID().uuidString)
            try fileManager.moveItem(at: networkSessionTemporaryLocation, to: tempOutputURL)
            return tempOutputURL
        } catch {
            throw FilesAccessError.errorMovingToTempLocation(error)
        }
    }

    public func moveFile(from temporaryLocation: URL, to finalUrl: URL, overwrite: Bool) throws -> URL {
        if fileManager.fileExists(atPath: finalUrl.path) {
            if overwrite {
                do {
                    try fileManager.removeItem(at: finalUrl)
                } catch {
                    throw FilesAccessError.errorMovingFromTempLocation(error)
                }
            } else {
                throw FilesAccessError.errorMovingFromTempLocationDestinationCollision(finalUrl.path)
            }
        }

        do {
            try fileManager.moveItem(at: temporaryLocation, to: finalUrl)
            return finalUrl
        } catch {
            throw FilesAccessError.errorMovingFromTempLocation(error)
        }
    }

    public func errorData(from location: URL) throws -> Data {
        do {
            let data = try fileManager.contents(atPath: location.path).orThrow()
            try fileManager.removeItem(at: location)
            return data
        } catch {
            throw FilesAccessError.couldNotReadErrorDataAtUrl(error)
        }
    }
}

protocol FileManagerProtocol {
    func fileExists(atPath: String) -> Bool
    func contents(atPath: String) -> Data?
    func createDirectory(at: URL, withIntermediateDirectories: Bool, attributes: [FileAttributeKey: Any]?) throws
    func moveItem(atPath: String, toPath: String) throws
    func moveItem(at: URL, to: URL) throws
    func removeItem(at: URL) throws
}

extension FileManager: FileManagerProtocol {}
