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
    func runInitAction() {
        if let initAction = self.initAction {
            switch initAction {
            case .locationSharing:
                startLocationSharing()
            case .fetchSMS:
                if let tripToken = initAction.getTripToken() {
                    fetchSMS(withTripToken: tripToken)
                }
            }
        }
    }
    
    func startLocationSharing() {
        if let presentingVC = HMViewControllerManager.shared.presentingViewController {
            TDSwiftAlert.showSingleButtonAlertWithCancel(title: "Message From Dispatch", message: "Dispatch center wants to know your status, share now?", actionBtnTitle: "Confirm", cancelBtnTitle: "Cancel", presentVC: presentingVC) {
                HMHeartBeat.shared.start()
            }
        }
    }
    
    func fetchSMS(withTripToken tripToken: String) {
        
    }
}
