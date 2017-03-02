///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

import Foundation
import UIKit
import WebKit

extension DropboxClientsManager {
    public static func authorizeFromController(_ sharedApplication: UIApplication, controller: UIViewController, openURL: @escaping ((URL) -> Void), browserAuth: Bool = false) {
        precondition(DropboxOAuthManager.sharedOAuthManager != nil, "Call `DropboxClientsManager.setupWithAppKey` or `DropboxClientsManager.setupWithTeamAppKey` before calling this method")
        DropboxOAuthManager.sharedOAuthManager.authorizeFromSharedApplication(MobileSharedApplication(sharedApplication: sharedApplication, controller: controller, openURL: openURL), browserAuth: browserAuth)
    }

    public static func setupWithAppKey(_ appKey: String, transportClient: DropboxTransportClient? = nil) {
        setupWithOAuthManager(appKey, oAuthManager: DropboxMobileOAuthManager(appKey: appKey), transportClient: transportClient)
    }

    public static func setupWithAppKeyMultiUser(_ appKey: String, transportClient: DropboxTransportClient? = nil, tokenUid: String?) {
        setupWithOAuthManagerMultiUser(appKey, oAuthManager: DropboxMobileOAuthManager(appKey: appKey), transportClient: transportClient, tokenUid: tokenUid)
    }

    public static func setupWithTeamAppKey(_ appKey: String, transportClient: DropboxTransportClient? = nil) {
        setupWithOAuthManagerTeam(appKey, oAuthManager: DropboxMobileOAuthManager(appKey: appKey), transportClient: transportClient)
    }

    public static func setupWithTeamAppKeyMultiUser(_ appKey: String, transportClient: DropboxTransportClient? = nil, tokenUid: String?) {
        setupWithOAuthManagerMultiUserTeam(appKey, oAuthManager: DropboxMobileOAuthManager(appKey: appKey), transportClient: transportClient, tokenUid: tokenUid)
    }
}


open class MobileSharedApplication: SharedApplication {
    let sharedApplication: UIApplication
    let controller: UIViewController
    let openURL: ((URL) -> Void)

    public init(sharedApplication: UIApplication, controller: UIViewController, openURL: @escaping ((URL) -> Void)) {
        // fields saved for app-extension safety
        self.sharedApplication = sharedApplication
        self.controller = controller
        self.openURL = openURL
    }

    open func presentErrorMessage(_ message: String, title: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)
        controller.present(alertController, animated: true, completion: { fatalError(message) })
    }

    open func presentErrorMessageWithHandlers(_ message: String, title: String, buttonHandlers: Dictionary<String, () -> Void>) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Retry", style: .default) { (_) in
            buttonHandlers["Retry"]!()
        })

        controller.present(alertController, animated: true, completion: {})
    }

    open func presentPlatformSpecificAuth(_ authURL: URL) -> Bool {
        presentExternalApp(authURL)
        return true
    }

    open func presentWebViewAuth(_ authURL: URL, tryIntercept: @escaping ((URL) -> Bool), cancelHandler: @escaping (() -> Void)) {
        let web = DropboxConnectController(
            URL: authURL,
            tryIntercept: tryIntercept,
            cancelHandler: cancelHandler
        )
        let navigationController = UINavigationController(rootViewController: web)
        controller.present(navigationController, animated: true, completion: nil)
    }

    open func presentBrowserAuth(_ authURL: URL) {
        presentExternalApp(authURL)
    }

    open func presentExternalApp(_ url: URL) {
        self.openURL(url)
    }

    open func canPresentExternalApp(_ url: URL) -> Bool {
        return self.sharedApplication.canOpenURL(url)
    }
}

open class DropboxConnectController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

    var onWillDismiss: ((_ didCancel: Bool) -> Void)?
    var tryIntercept: ((_ url: URL) -> Bool)?

    var cancelButton: UIBarButtonItem?
    var cancelHandler: (() -> Void) = {}

    var indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public init(URL: Foundation.URL, tryIntercept: @escaping ((_ url: Foundation.URL) -> Bool), cancelHandler: @escaping (() -> Void)) {
        super.init(nibName: nil, bundle: nil)
        self.startURL = URL
        self.tryIntercept = tryIntercept
        self.cancelHandler = cancelHandler
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Link to Dropbox"
        self.webView = WKWebView(frame: self.view.bounds)

        indicator.center = view.center
        self.webView.addSubview(indicator)
        indicator.startAnimating()

        self.view.addSubview(self.webView)

        self.webView.navigationDelegate = self

        self.view.backgroundColor = UIColor.white

        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DropboxConnectController.cancel(_:)))
        self.navigationItem.rightBarButtonItem = self.cancelButton
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !webView.canGoBack {
            if nil != startURL {
                loadURL(startURL!)
            } else {
                webView.loadHTMLString("There is no `startURL`", baseURL: nil)
            }
        }
    }

    open func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                                                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let callback = self.tryIntercept {
            if callback(url) {
                self.dismiss(true)
                return decisionHandler(.cancel)
            }
        }
        return decisionHandler(.allow)
    }

    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }

    open var startURL: URL? {
        didSet(oldURL) {
            if nil != startURL && nil == oldURL && isViewLoaded {
                loadURL(startURL!)
            }
        }
    }

    open func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    func showHideBackButton(_ show: Bool) {
        navigationItem.leftBarButtonItem = show ? UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(DropboxConnectController.goBack(_:))) : nil
    }

    func goBack(_ sender: AnyObject?) {
        webView.goBack()
    }

    func cancel(_ sender: AnyObject?) {
        dismiss(true, animated: (sender != nil))

        self.cancelHandler()
    }

    func dismiss(_ animated: Bool) {
        dismiss(false, animated: animated)
    }

    func dismiss(_ asCancel: Bool, animated: Bool) {
        webView.stopLoading()

        self.onWillDismiss?(asCancel)
        presentingViewController?.dismiss(animated: animated, completion: nil)
    }
}
