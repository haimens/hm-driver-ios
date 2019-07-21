import Foundation
import UIKit

enum HMPushActionType {
    case locationSharing
    case fetchSMS(tripToken: String)
    
    func getTripToken() -> String? {
        switch self {
        case let .fetchSMS(tripToken: token):
            return token
        default:
            return nil
        }
    }
}

class HMPushActionManager {
    // Singelton instance
    private init() {}
    static let shared = HMPushActionManager()
    
    // Action need to be performed on first launch
    var initAction: HMPushActionType?
    
    // Run correspond init action if available
    func runInitAction(currentVC vc: UIViewController) {
        if let initAction = self.initAction {
            switch initAction {
            case .locationSharing:
                startLocationSharing(promptAtVC: vc)
            case .fetchSMS:
                if let tripToken = initAction.getTripToken() {
                    fetchSMS(withTripToken: tripToken)
                }
            }
        }
    }
    
    func startLocationSharing(promptAtVC vc: UIViewController) {
        TDSwiftAlert.showSingleButtonAlert(title: "Hi", message: "Hi", actionBtnTitle: "OK", presentVC: vc, btnAction: nil)
    }
    
    func fetchSMS(withTripToken tripToken: String) {
        
    }
}
