//
//  DropboxConnectController.swift
//  SwiftyDropbox
//
//  Created by krivoblotsky on 1/10/16.
//  Copyright © 2016 Home. All rights reserved.
//

#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

import WebKit
import Foundation

/**
*  That's the only legal trick to subclass *ViewController easily without huge '#if os' madness
*/

#if os(iOS) || os(watchOS) || os(tvOS)
    
internal class DropboxConnectMultiBaseController:UIViewController {}
    
#else
    
internal class DropboxConnectMultiBaseController:NSViewController {}
    
#endif

internal class DropboxConnectBaseController: DropboxConnectMultiBaseController, WKNavigationDelegate {
    
    //Properties
    
    var webView : WKWebView!
    
    var onWillDismiss: ((didCancel: Bool) -> Void)?
    var tryIntercept: ((url: NSURL) -> Bool)?
    
    //Constructors
    
    init() {
        #if os(iOS) || os(watchOS) || os(tvOS)
        super.init(nibName: nil, bundle: nil)
        #else
        super.init(nibName: nil, bundle: nil)!
        #endif
    }
    
    init(URL: NSURL, tryIntercept: ((url: NSURL) -> Bool)) {
        #if os(iOS) || os(watchOS) || os(tvOS)
            super.init(nibName: nil, bundle: nil)
        #else
            super.init(nibName: nil, bundle: nil)!
        #endif
        self.startURL = URL
        self.tryIntercept = tryIntercept
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Lifetime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Link to Dropbox"
        self.webView = WKWebView(frame: self.view.bounds)
        self.view.addSubview(self.webView)
        
        self.webView.navigationDelegate = self
    }
    
    /**
     Loads the http request
     
     - parameter url: NSURL
     */
    internal func loadURL(url: NSURL) {

        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    internal func preloadURL() -> Void {
        if !webView.canGoBack {
            if nil != startURL {
                loadURL(startURL!)
            }
            else {
                webView.loadHTMLString("There is no `startURL`", baseURL: nil)
            }
        }
    }
    
    internal var startURL: NSURL? {
        didSet(oldURL) {
            
            if nil != startURL && nil == oldURL && self.viewActuallyLoaded() {
                loadURL(startURL!)
            }
        }
    }
    
    //MARK: WKNavigationDelegate
    
    internal func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.URL, callback = self.tryIntercept {
                if callback(url: url) {
                    self.dismiss(true)
                    return decisionHandler(.Cancel)
                }
            }
            return decisionHandler(.Allow)
    }
    
    func goBack(sender: AnyObject?) {
        webView.goBack()
    }
    
    func cancel(sender: AnyObject?) {
        dismiss(true, animated: (sender != nil))
    }
    
    func dismiss(animated: Bool) {
        dismiss(false, animated: animated)
    }
    
    func dismiss(asCancel: Bool, animated: Bool) {
        webView.stopLoading()
        
        self.onWillDismiss?(didCancel: asCancel)
        self.dismissCurrentViewController(animated, completion: nil)
    }
}

#if os(iOS) || os(watchOS) || os(tvOS)

//iOS
internal class DropboxConnectController: DropboxConnectBaseController {
    
    var cancelButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
        self.navigationItem.rightBarButtonItem = self.cancelButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        preloadURL()
    }
    
    func showHideBackButton(show: Bool) {
        navigationItem.leftBarButtonItem = show ? UIBarButtonItem(barButtonSystemItem: .Rewind, target: self, action: "goBack:") : nil
    }
}
    
#else

//OSX
internal class DropboxConnectController: DropboxConnectBaseController {
    
    override func loadView() {
        self.view = NSView()
        self.view.frame = NSRect(x: 0, y: 0, width: 500, height: 400)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preloadURL()
    }
}
    
#endif
