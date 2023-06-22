//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

@available(iOS 13.0, *)
extension UIApplication {
    public func findKeyWindow() -> UIWindow? {
        connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .filter(\.isKeyWindow).first
    }
}

#endif
