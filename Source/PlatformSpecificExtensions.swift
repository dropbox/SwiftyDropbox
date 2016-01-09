//
//  PlatformSpecificExtensions.swift
//  SwiftyDropbox
//
//  Created by krivoblotsky on 1/9/16.
//  Copyright © 2016 Home. All rights reserved.
//

#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

import Foundation

public protocol PlatformSpecificController
{
    /**
     Presents an error message for user
     
     - parameter message:    String
     - parameter completion: () -> Void
     */
    func presentErrorMessage(message:String, completion: () -> Void)
    
    /**
     Dismisses current view controller
     
     - parameter animated: Bool
     - parameter completion: () -> Void
     */
    func dismissCurrentViewController(animated:Bool, completion: (() -> Void)?)
    
    /**
     Presents the controller modally
     
     - parameter controller: PlatformSpecificController
     - parameter animated:   Bool
     - parameter completion: (() -> Void)?
     */
    
#if os(iOS) || os(watchOS) || os(tvOS)
    func presentViewControllerModally(
        controller:UIViewController,
        animated:Bool,
        completion: (() -> Void)?)
#else
    func presentViewControllerModally(
        controller:NSViewController,
        animated:Bool,
        completion: (() -> Void)?)
#endif
    
}

#if os(OSX)
    
    //NSApplication extensions
    //
    extension NSApplication
    {
        /**
         Checks if application can handle given url.
         
         - parameter url: NSURL
         
         - returns: Bool
         */
        public func canOpenURL(url:NSURL) -> Bool
        {
            return false
        }
        
        /**
         Opens the application with given url
         
         - parameter url: NSURL
         
         - returns: Bool
         */
        public func openURL(url:NSURL) -> Bool
        {
            if let authResult = Dropbox.handleRedirectURL(url) {
                switch authResult {
                case .Success(let token):
                    print("Success! User is logged into Dropbox with token: \(token)")
                case .Error(let error, let description):
                    print("Error \(error): \(description)")
                }
            }
            return true
        }
    }
    
    //NSViewController extensions
    //
    extension NSViewController:PlatformSpecificController
    {
        /**
         See: protocol PlatformSpecificController
         */
        public func presentErrorMessage(message: String, completion: () -> Void)
        {
            let error = NSError(domain: "", code: 123, userInfo: [NSLocalizedDescriptionKey:message])
            self.presentError(error)
            completion()
        }
        
        public func dismissCurrentViewController(animated:Bool, completion: (() -> Void)?)
        {
            self.dismissController(nil)
            if let handler = completion { handler() }
        }
        
        public func presentViewControllerModally(
            controller:NSViewController,
            animated:Bool,
            completion: (() -> Void)?)
        {
            self.presentViewControllerAsModalWindow(controller)
            if let handler = completion { handler() }
        }
    }
    
#else
    
    extension UIViewController:PlatformSpecificController
    {
        /**
         See: protocol PlatformSpecificController
         */
        public func presentErrorMessage(message: String, completion: () -> Void)
        {
            let alertController = UIAlertController(
                title: "SwiftyDropbox Error",
                message: message,
                preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alertController, animated: true, completion: completion )
        }
        
        public func dismissCurrentViewController(animated:Bool, completion: (() -> Void)?)
        {
            presentingViewController?.dismissViewControllerAnimated(animated, completion: completion)
        }
        
        public func presentViewControllerModally(
            controller:UIViewController,
            animated:Bool,
            completion: (() -> Void)?)
        {
            self.presentViewController(controller, animated: true, completion: completion)
        }
    }
#endif
