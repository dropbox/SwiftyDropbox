//
//  Copyright (c) 2022 Dropbox Inc. All rights reserved.
//

import Foundation
import SystemConfiguration

class Reachability {
    /// From http://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647.
    ///
    /// This method uses `SCNetworkReachabilityCreateWithAddress` to create a reference to monitor the example host
    /// defined by our zeroed `zeroAddress` struct. From this reference, we can extract status flags regarding the
    /// reachability of this host, using `SCNetworkReachabilityGetFlags`.

    class func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
