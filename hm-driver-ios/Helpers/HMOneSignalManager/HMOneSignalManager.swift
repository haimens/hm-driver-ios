import Foundation
import OneSignal

class HMOneSignalManager {
    static func setExternalUserId() {
        // If driver token available
        if let driverToken = TDSwiftHavana.shared.auth?.driver_token {
            OneSignal.setExternalUserId(driverToken)
        }
    }
}
