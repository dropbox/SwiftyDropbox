import Foundation
import UIKit
import WebKit
import SystemConfiguration

extension Dropbox {
    public static func authorizeFromController(sharedApplication: UIApplication, controller: UIViewController, openURL: (NSURL -> Void), browserAuth: Bool = false) {
        precondition(DropboxAuthManager.sharedAuthManager != nil, "Call `Dropbox.setupWithAppKey` or `Dropbox.setupWithTeamAppKey` before calling this method")
        precondition(Dropbox.authorizedClient == nil && Dropbox.authorizedTeamClient == nil, "A Dropbox client is already authorized")
        DropboxAuthManager.sharedAuthManager.authorizeFromSharedApplication(MobileSharedApplication(sharedApplication: sharedApplication, controller: controller, openURL: openURL), browserAuth: browserAuth)
    }

    public static func setupWithAppKey(appKey: String) {
        setupWithAppKey(appKey, sharedAuthManager: DropboxMobileAuthManager(appKey: appKey))
    }

    public static func setupWithTeamAppKey(appKey: String) {
        setupWithTeamAppKey(appKey, sharedAuthManager: DropboxMobileAuthManager(appKey: appKey))
    }
}


public class MobileSharedApplication: SharedApplication {
    let sharedApplication: UIApplication
    let controller: UIViewController
    let openURL: (NSURL -> Void)

    public init(sharedApplication: UIApplication, controller: UIViewController, openURL: (NSURL -> Void)) {
        // fields saved for app-extension safety
        self.sharedApplication = sharedApplication
        self.controller = controller
        self.openURL = openURL
    }

    public func presentErrorMessage(message: String, title: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        controller.presentViewController(alertController, animated: true, completion: { fatalError(message) })
    }

    public func presentErrorMessageWithHandlers(message: String, title: String, buttonHandlers: Dictionary<String, () -> Void>) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Retry", style: .Default) { (_) in
            buttonHandlers["Retry"]!()
        })

        controller.presentViewController(alertController, animated: true, completion: {})
    }

    public func presentPlatformSpecificAuth(authURL: NSURL) -> Bool {
        presentExternalApp(authURL)
        return true
    }

    public func presentWebViewAuth(authURL: NSURL, tryIntercept: (NSURL -> Bool), cancelHandler: (() -> Void)) {
        let web = DropboxConnectController(
            URL: authURL,
            tryIntercept: tryIntercept,
            cancelHandler: cancelHandler
        )
        let navigationController = UINavigationController(rootViewController: web)
        controller.presentViewController(navigationController, animated: true, completion: nil)
    }

    public func presentBrowserAuth(authURL: NSURL) {
        presentExternalApp(authURL)
    }

    public func presentExternalApp(url: NSURL) {
        self.openURL(url)
    }

    public func canPresentExternalApp(url: NSURL) -> Bool {
        return self.sharedApplication.canOpenURL(url)
    }
}

public class DropboxConnectController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

    var onWillDismiss: ((didCancel: Bool) -> Void)?
    var tryIntercept: ((url: NSURL) -> Bool)?

    var cancelButton: UIBarButtonItem?
    var cancelHandler: (() -> Void) = {}

    var indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public init(URL: NSURL, tryIntercept: ((url: NSURL) -> Bool), cancelHandler: (() -> Void)) {
        super.init(nibName: nil, bundle: nil)
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

        indicator.center = view.center
        self.webView.addSubview(indicator)
        indicator.startAnimating()

        self.view.addSubview(self.webView)

        self.webView.navigationDelegate = self

        self.view.backgroundColor = UIColor.whiteColor()

        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(DropboxConnectController.cancel(_:)))
        self.navigationItem.rightBarButtonItem = self.cancelButton
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !webView.canGoBack {
            if nil != startURL {
                loadURL(startURL!)
            } else {
                webView.loadHTMLString("There is no `startURL`", baseURL: nil)
            }
        }
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
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }

    public var startURL: NSURL? {
        didSet(oldURL) {
            if nil != startURL && nil == oldURL && isViewLoaded() {
                loadURL(startURL!)
            }
        }
    }

    public func loadURL(url: NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }

    func showHideBackButton(show: Bool) {
        navigationItem.leftBarButtonItem = show ? UIBarButtonItem(barButtonSystemItem: .Rewind, target: self, action: #selector(DropboxConnectController.goBack(_:))) : nil
    }

    func goBack(sender: AnyObject?) {
        webView.goBack()
    }

    func cancel(sender: AnyObject?) {
        dismiss(true, animated: (sender != nil))

        self.cancelHandler()
    }

    func dismiss(animated: Bool) {
        dismiss(false, animated: animated)
    }

    func dismiss(asCancel: Bool, animated: Bool) {
        webView.stopLoading()

        self.onWillDismiss?(didCancel: asCancel)
        presentingViewController?.dismissViewControllerAnimated(animated, completion: nil)
    }
}
