//
//  BrowserAuth.swift
//  SwiftyDropbox
//
//  Created by krivoblotsky on 1/24/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

internal class BaseBrowser:NSObject /* NSObject required by NSAppleEvent */
{
    var url:NSURL
    var handler: ((url: NSURL?) -> Void)
    
    /**
     Basic constructor
     
     - parameter url:     NSURL
     - parameter handler: (url: NSURL?) -> Void)
     
     - returns: BrowserAuth
     */
    init(url:NSURL, handler:(url: NSURL?) -> Void)
    {
        self.url = url
        self.handler = handler
    }
    
    //Methods to ovverride
    
    /**
    Represents the status of browser availability
    
    - returns: Bool
    */
    class func available() -> Bool { return false }
    
    /**
     Prepares the event handler
     */
    private func prepareForAuth() -> Void {}
    
    /**
     Runs auth process. Uses implicit retian cycle to keep the reference while auth
     
     - returns: Bool if auth started
     */
    func authentificate() -> Bool { return false }
}

#if os(OSX)

internal class BrowserAuth:BaseBrowser
{
    let appleEventManager = NSAppleEventManager.sharedAppleEventManager()
    let workspace = NSWorkspace.sharedWorkspace()
    
    deinit
    {
        //Remove the handler
        self.appleEventManager.removeEventHandlerForEventClass(
            UInt32(kInternetEventClass),andEventID:
            UInt32(kAEGetURL))
    }
    
    /**
     Represents the status of browser availability
     
     - returns: Bool
     */
    override class func available() -> Bool
    {
        return true
    }
    
    /**
     Runs auth process. Uses implicit retian cycle to keep the reference while auth
     
     - returns: Bool if auth started
     */
    override func authentificate() -> Bool
    {
        //Prepeare for apple event handling
        self.prepareForAuth()
        
        //Try to open safari
        return self.workspace.openURL(url)
    }
    
    /**
     Prepares the event handler
     */
    private override func prepareForAuth() -> Void
    {
        //Setup the event handler
        self.appleEventManager.setEventHandler(
            self,
            andSelector: Selector("eventHandled:"),
            forEventClass: UInt32(kInternetEventClass),
            andEventID: UInt32(kAEGetURL))
    }
    
    /**
     Handles the kInternetEventClass
     
     - parameter event: NSAppleEventDescriptor
     */
    func eventHandled(event:NSAppleEventDescriptor) -> Void
    {
        //Check for keyword
        guard let keyword = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject)) else {
            self.handler(url:nil)
            return
        }
        
        //Check for url string
        guard let urlString = keyword.stringValue else {
            self.handler(url:nil)
            return
        }
        
        //Notify about result
        self.handler(url:NSURL(string: urlString))
    }
}
    
#elseif os(iOS)
    
internal class BrowserAuth:BaseBrowser
{
    //Do nothing on iOS?
}

#endif

