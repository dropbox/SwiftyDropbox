//
//  DBChunkInputStream.swift
//  
//
//  Created by ben on 6/20/20.
//

import Foundation

class DBChunkInputStream: InputStream, StreamDelegate {
	let parentStream: InputStream!
	var parentStreamStatus = InputStream.Status.notOpen
	
	var startBytes: Int
	var endBytes: Int
	var totalBytesToRead: Int
	var totalBytesRead = 0
	
	weak var actualDelegate: StreamDelegate?
	
	init(fileUrl: URL, startBytes start: Int, endBytes end: Int) {
		assert(end > start, "End location \(end) needs to be greater than start location \(start)")

		parentStream = InputStream(url: fileUrl)
		startBytes = start
		endBytes = end
		totalBytesToRead = end - start
		
		
		super.init(data: Data())
		
		parentStream?.delegate = self
		self.delegate = self
	}
	
	override func open() {
		if parentStream == nil { return }
		parentStream.open()
		parentStream.setProperty(startBytes, forKey: .fileCurrentOffsetKey)
		parentStreamStatus = .open
	}
	
	override func close() {
		parentStream?.close()
		parentStreamStatus = .closed
	}
	
	override var delegate: StreamDelegate? {
		get { actualDelegate }
		set { actualDelegate = newValue }
	}
	
	override func schedule(in aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {
		parentStream?.schedule(in: aRunLoop, forMode: mode)
	}
	
	override func remove(from aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {
		parentStream?.remove(from: aRunLoop, forMode: mode)
	}
	
	override func setProperty(_ property: Any?, forKey key: Stream.PropertyKey) -> Bool {
		parentStream?.setProperty(property, forKey: key) ?? false
	}
	
	override func property(forKey key: Stream.PropertyKey) -> Any? {
		parentStream?.property(forKey: key)
	}
	
	override var streamStatus: Stream.Status { parentStreamStatus }
	
	override var streamError: Error? { parentStream.streamError }
	
	override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
		var bytesToRead = len
		let bytesRemaining = totalBytesToRead - totalBytesRead
		if len > bytesRemaining { bytesToRead = bytesRemaining }
		let bytesRead = parentStream.read(buffer, maxLength: bytesToRead)
		totalBytesRead += bytesRead
		return bytesRead
	}
	
	override func getBuffer(_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>, length len: UnsafeMutablePointer<Int>) -> Bool {
		return false
	}
	
	override var hasBytesAvailable: Bool {
		let bytesRemaining = totalBytesToRead - totalBytesRead
		if bytesRemaining == 0 {
			self.parentStreamStatus = .atEnd
			return false
		}
		return parentStream.hasBytesAvailable
	}
}
