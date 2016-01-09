//
//  DropBoxEntry.swift
//  SwiftyDropbox
//
//  Created by krivoblotsky on 1/9/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Cocoa

@objc class DropBoxEntry: NSObject
{
    dynamic var thumbnail:NSImage?
    var filename:String
    
    init(name:String)
    {
        self.filename = name
        super.init()
        self.obtainImage()
    }
    
    private func obtainImage() -> Void
    {
        let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            // generate a unique name for this file in case we've seen it before
            let UUID = NSUUID().UUIDString
            let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
            return directoryURL.URLByAppendingPathComponent(pathComponent)
        }
        
        Dropbox.authorizedClient!.files.getThumbnail(path: "/\(filename)", format: .Png, size: .W128h128, destination: destination).response { response, error in
            if let (_, url) = response, data = NSData(contentsOfURL: url), image = NSImage(data: data) {
                
                self.thumbnail = image
                
            } else {
                Swift.print("Error downloading file from Dropbox: \(error!)")
            }
        }
    }
}
