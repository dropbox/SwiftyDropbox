import Foundation
import AppKit
import WebKit

extension Dropbox {
    public static func authorizeFromController(sharedWorkspace: NSWorkspace, controller: NSViewController, openURL: (NSURL -> Void), browserAuth: Bool = false) {
        precondition(DropboxAuthManager.sharedAuthManager != nil, "Call `Dropbox.setupWithAppKey` or `Dropbox.setupWithTeamAppKey` before calling this method")
        precondition(Dropbox.authorizedClient == nil && Dropbox.authorizedTeamClient == nil, "A Dropbox client is already authorized")
        DropboxAuthManager.sharedAuthManager.authorizeFromSharedApplication(DesktopSharedApplication(sharedWorkspace: sharedWorkspace, controller: controller, openURL: openURL), browserAuth: browserAuth)
    }

    public static func setupWithAppKey(appKey: String) {
        setupWithAppKey(appKey, sharedAuthManager: DropboxAuthManager(appKey: appKey))
    }

    public static func setupWithTeamAppKey(appKey: String) {
        setupWithTeamAppKey(appKey, sharedAuthManager: DropboxAuthManager(appKey: appKey))
    }
}


public class DesktopSharedApplication: SharedApplication {
    let sharedWorkspace: NSWorkspace
    let controller: NSViewController
    let openURL: (NSURL -> Void)

    public init(sharedWorkspace: NSWorkspace, controller: NSViewController, openURL: (NSURL -> Void)) {
        self.sharedWorkspace = sharedWorkspace
        self.controller = controller
        self.openURL = openURL
    }

    public func presentErrorMessage(message: String, title: String) {
        let error = NSError(domain: "", code: 123, userInfo: [NSLocalizedDescriptionKey:message])
        controller.presentError(error)
        fatalError(message)
    }

    public func presentErrorMessageWithHandlers(message: String, title: String, buttonHandlers: Dictionary<String, () -> Void>) {
        presentErrorMessage(message, title: title)
    }

    // no platform-specific auth methods for OS X
    public func presentPlatformSpecificAuth(authURL: NSURL) -> Bool {
        return false
    }

    public func presentWebViewAuth(authURL: NSURL, tryIntercept: (NSURL -> Bool), cancelHandler: (() -> Void)) {
        let web = DropboxConnectController(
            URL: authURL,
            tryIntercept: tryIntercept,
            cancelHandler: cancelHandler
        )
        let navigationController = web
        self.controller.presentViewControllerAsModalWindow(navigationController)
    }

    public func presentBrowserAuth(authURL: NSURL) {
        self.presentExternalApp(authURL)
    }

    public func presentExternalApp(url: NSURL) {
        self.openURL(url)
    }

    public func canPresentExternalApp(url: NSURL) -> Bool {
        return true
    }
}


public class DropboxConnectController: NSViewController, NSWindowDelegate, WKNavigationDelegate {
    var webView: WKWebView!

    var tryIntercept: ((url: NSURL) -> Bool)?

    var cancelHandler: (() -> Void) = {}

    var indicator = NSProgressIndicator(frame: NSRect(x: 20, y: 20, width: 30, height: 30))

    public init() {
        super.init(nibName: nil, bundle: nil)!
    }

    public init(URL: NSURL, tryIntercept: ((url: NSURL) -> Bool), cancelHandler: (() -> Void)) {
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
        indicator.style = .SpinningStyle
        indicator.startAnimation(self)

        self.view.addSubview(self.webView)
        self.webView.navigationDelegate = self
        self.webView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]

        self.view.window?.delegate = self
    }

    public override func viewWillAppear() {
        super.viewWillAppear()
        if !webView.canGoBack {
            if startURL != nil {
                loadURL(startURL!)
            } else {
                webView.loadHTMLString("There is no `startURL`", baseURL: nil)
            }
        }
    }

    public func windowShouldClose(sender: AnyObject) -> Bool {
        self.cancelHandler()
        return true
    }

    public func webView(webView: WKWebView,
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

    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        indicator.stopAnimation(self)
        indicator.removeFromSuperview()
    }

    public var startURL: NSURL? {
        didSet(oldURL) {
            if nil != startURL && nil == oldURL && self.viewLoaded {
                loadURL(startURL!)
            }
        }
    }

    override public func loadView() {
        self.view = NSView()
        self.view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
    }

    public func loadURL(url: NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }

    func goBack(sender: AnyObject?) {
        webView.goBack()
    }

    func dismiss(animated: Bool) {
        dismiss(false, animated: animated)
    }

    func dismiss(asCancel: Bool, animated: Bool) {
        webView.stopLoading()
        self.dismissController(nil)
    }
}
