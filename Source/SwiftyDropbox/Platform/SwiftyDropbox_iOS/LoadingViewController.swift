///
/// Copyright (c) 2020 Dropbox, Inc. All rights reserved.
///

#if canImport(UIKit)

import Foundation
import UIKit

/// A VC with a loading spinner at its view center.
class LoadingViewController: UIViewController {
    private let loadingSpinner: UIActivityIndicatorView

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        if #available(iOS 13.0, *) {
            loadingSpinner = UIActivityIndicatorView(style: .large)
        } else {
            loadingSpinner = UIActivityIndicatorView(style: .whiteLarge)
        }
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(loadingSpinner)
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadingSpinner.startAnimating()
    }
}

#endif
