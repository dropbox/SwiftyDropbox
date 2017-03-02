///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation
import AppKit
import WebKit

extension DropboxClientsManager {
    public static func authorizeFromController(sharedWorkspace: NSWorkspace, controller: NSViewController, openURL: @escaping ((URL) -> Void), browserAuth: Bool = false) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` before calling this method")
        DropboxOAuthManager.sharedOAuthManager.authorizeFromSharedApplication(DesktopSharedApplication(sharedWorkspace: sharedWorkspace, controller: controller, openURL: openURL), browserAuth: browserAuth)
    }

    public static func setupWithAppKeyDesktop(_ appKey: String, transportClient: DropboxTransportClient? = nil) {
        setupWithOAuthManager(appKey, oAuthManager: DropboxDesktopOAuthManager(appKey: appKey), transportClient: transportClient)
    }

    public static func setupWithAppKeyMultiUserDesktop(_ appKey: String, transportClient: DropboxTransportClient? = nil, tokenUid: String?) {
        setupWithOAuthManagerMultiUser(appKey, oAuthManager: DropboxDesktopOAuthManager(appKey: appKey), transportClient: transportClient, tokenUid: tokenUid)
    }

    public static func setupWithTeamAppKeyDesktop(_ appKey: String, transportClient: DropboxTransportClient? = nil) {
        setupWithOAuthManagerTeam(appKey, oAuthManager: DropboxDesktopOAuthManager(appKey: appKey), transportClient: transportClient)
    }

    public static func setupWithTeamAppKeyMultiUserDesktop(_ appKey: String, transportClient: DropboxTransportClient? = nil, tokenUid: String?) {
        setupWithOAuthManagerMultiUserTeam(appKey, oAuthManager: DropboxDesktopOAuthManager(appKey: appKey), transportClient: transportClient, tokenUid: tokenUid)
    }
}


public class DesktopSharedApplication: SharedApplication {
    let sharedWorkspace: NSWorkspace
    let controller: NSViewController
    let openURL: ((URL) -> Void)

    public init(sharedWorkspace: NSWorkspace, controller: NSViewController, openURL: @escaping ((URL) -> Void)) {
        self.sharedWorkspace = sharedWorkspace
        self.controller = controller
        self.openURL = openURL
    }

    public func presentErrorMessage(_ message: String, title: String) {
        let error = NSError(domain: "", code: 123, userInfo: [NSLocalizedDescriptionKey:message])
        controller.presentError(error)
        fatalError(message)
    }

    public func presentErrorMessageWithHandlers(_ message: String, title: String, buttonHandlers: Dictionary<String, () -> Void>) {
        presentErrorMessage(message, title: title)
    }

    // no platform-specific auth methods for OS X
    public func presentPlatformSpecificAuth(_ authURL: URL) -> Bool {
        return false
    }

    public func presentWebViewAuth(_ authURL: URL, tryIntercept: @escaping ((URL) -> Bool), cancelHandler: @escaping (() -> Void)) {
        let web = DropboxConnectController(
            URL: authURL,
            tryIntercept: tryIntercept,
            cancelHandler: cancelHandler
        )
        let navigationController = web
        self.controller.presentViewControllerAsModalWindow(navigationController)
    }

    public func presentBrowserAuth(_ authURL: URL) {
        self.presentExternalApp(authURL)
    }

    public func presentExternalApp(_ url: URL) {
        self.openURL(url)
    }

    public func canPresentExternalApp(_ url: URL) -> Bool {
        return true
    }
}


public class DropboxConnectController: NSViewController, NSWindowDelegate, WKNavigationDelegate {
    var webView: WKWebView!

    var tryIntercept: ((_ url: URL) -> Bool)?

    var cancelHandler: (() -> Void) = {}

    var indicator = NSProgressIndicator(frame: NSRect(x: 20, y: 20, width: 30, height: 30))

    public init() {
        super.init(nibName: nil, bundle: nil)!
    }

    public init(URL: URL, tryIntercept: @escaping ((_ url: URL) -> Bool), cancelHandler: @escaping (() -> Void)) {
        super.init(nibName: nil, bundle: nil)!
        self.startURL = URL
        self.tryIntercept = tryIntercept
        self.cancelHandler = cancelHandler
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Link to Dropbox"
        self.webView = WKWebView(frame: self.view.bounds)

        indicator.setFrameOrigin(NSMakePoint(
            (NSWidth(self.webView.bounds) - NSWidth(indicator.frame)) / 2,
            (NSHeight(self.webView.bounds) - NSHeight(indicator.frame)) / 2
        ))
        self.webView.addSubview(indicator)
        indicator.style = .spinningStyle
        indicator.startAnimation(self)

        self.view.addSubview(self.webView)
        self.webView.navigationDelegate = self
        self.webView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]

        self.view.window?.delegate = self
    }

    public override func viewWillAppear() {
        super.viewWillAppear()
        if !webView.canGoBack {
            if startURL != nil {
                loadURL(url: startURL!)
            } else {
                webView.loadHTMLString("There is no `startURL`", baseURL: nil)
            }
        }
    }

    public func windowShouldClose(_ sender: Any) -> Bool {
        self.cancelHandler()
        return true
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if let url = navigationAction.request.url, let callback = self.tryIntercept {
            if callback(url) {
                self.dismiss(true)
                return decisionHandler(.cancel)
            }
        }
        return decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimation(self)
        indicator.removeFromSuperview()
    }

    public var startURL: URL? {
        didSet(oldURL) {
            if nil != startURL && nil == oldURL && self.isViewLoaded {
                loadURL(url: startURL!)
            }
        }
    }

    override public func loadView() {
        self.view = NSView()
        self.view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
    }

    public func loadURL(url: URL) {
        webView.load(URLRequest(url: url as URL) as URLRequest)
    }

    func goBack(sender: AnyObject?) {
        webView.goBack()
    }

    func dismiss(animated: Bool) {
        dismiss(asCancel: false, animated: animated)
    }

    func dismiss(asCancel: Bool, animated: Bool) {
        webView.stopLoading()
        self.dismiss(nil)
    }
}
