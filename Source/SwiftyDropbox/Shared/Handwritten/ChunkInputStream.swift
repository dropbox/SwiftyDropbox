///
/// Copyright (c) 2020 Dropbox, Inc. All rights reserved.
///
/// Swift translation of the DBChunkInputStream ObjC class, without overrides of CFReadStream bridged methods
/// which are not necessary now.
/// Original files:
/// https://github.com/dropbox/SwiftyDropbox/blob/6.0.1/Source/SwiftyDropbox/Shared/Handwritten/DBChunkInputStream.h
/// https://github.com/dropbox/SwiftyDropbox/blob/6.0.1/Source/SwiftyDropbox/Shared/Handwritten/DBChunkInputStream.m
///

import Foundation

/// Subclass of `InputStream` to enforce "bounds" on file stream, for chunk uploading.
class ChunkInputStream: InputStream, StreamDelegate {
    private let internalStream: InputStream?
    private var internalStreamStatus = InputStream.Status.notOpen
    private var startBytes: Int
    private var totalBytesToRead: Int
    private var totalBytesRead: Int
    private weak var streamDelegate: StreamDelegate?

    ///
    /// Full constructor.
    ///
    /// - Parameters:
    ///     - fileUrl: The file to stream.
    ///     - startBytes: The starting position of the file stream, relative to the beginning of the file.
    ///     - endBytes: The ending position of the file stream, relative to the beginning of the file.
    /// - returns An initialized ChunkInputStream instance.
    ///
    init(fileUrl: URL, startBytes start: Int, endBytes end: Int) {
        precondition(end > start, "End location \(end) needs to be greater than start location \(start)")

        // TODO: Consider making this init method failable and return nil if the internalStream's init fails.
        self.internalStream = InputStream(url: fileUrl)
        self.startBytes = start
        self.totalBytesToRead = end - start
        self.totalBytesRead = 0
        super.init(data: Data())
        self.internalStream?.delegate = self
        self.delegate = self
    }

    // MARK: InputStream overrides

    override var hasBytesAvailable: Bool {
        let bytesRemaining = totalBytesToRead - totalBytesRead
        if bytesRemaining == 0 {
            return false
        }
        return internalStream?.hasBytesAvailable ?? false
    }

    override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        guard let internalStream = internalStream else { return 0 }
        let bytesRemaining = totalBytesToRead - totalBytesRead
        let bytesToRead = min(len, bytesRemaining)
        let bytesRead = internalStream.read(buffer, maxLength: bytesToRead)
        if bytesRead > 0 {
            totalBytesRead += bytesRead
            if totalBytesRead == totalBytesToRead {
                internalStreamStatus = .atEnd
            }
        }
        return bytesRead
    }

    override func getBuffer(
        _ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>, length len: UnsafeMutablePointer<Int>
    ) -> Bool {
        return false
    }

    // MARK: Stream overrides

    override var delegate: StreamDelegate? {
        get {
            streamDelegate
        }
        set {
            streamDelegate = newValue ?? self
        }
    }

    override var streamStatus: Stream.Status {
        internalStreamStatus
    }

    override var streamError: Error? {
        internalStream?.streamError
    }

    override func open() {
        guard let internalStream = internalStream else { return }
        internalStream.open()
        internalStream.setProperty(startBytes, forKey: .fileCurrentOffsetKey)
        internalStreamStatus = .open
    }

    override func close() {
        guard let internalStream = internalStream else { return }
        internalStream.close()
        internalStreamStatus = .closed
    }

    override func schedule(in aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {
        internalStream?.schedule(in: aRunLoop, forMode: mode)
    }

    override func remove(from aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {
        internalStream?.remove(from: aRunLoop, forMode: mode)
    }

    override func property(forKey key: Stream.PropertyKey) -> Any? {
        internalStream?.property(forKey: key)
    }

    override func setProperty(_ property: Any?, forKey key: Stream.PropertyKey) -> Bool {
        internalStream?.setProperty(property, forKey: key) ?? false
    }
}
