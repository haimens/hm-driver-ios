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
            // Remove init action
            self.initAction = nil
            
            switch initAction {
            case .locationSharing:
                startLocationSharing()
            case .fetchSMS:
                if let tripToken = initAction.getTripToken() {
                    presentMessagingVC(withTripToken: tripToken)
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
    
    func newMessageAlert(withTripToken tripToken: String) {
        if let presentingVC = HMViewControllerManager.shared.presentingViewController {
            TDSwiftAlert.showSingleButtonAlertWithCancel(title: "Message Center", message: "You've received a new message, view now?", actionBtnTitle: "View", cancelBtnTitle: "Cancel", presentVC: presentingVC) {
                self.presentMessagingVC(withTripToken: tripToken)
            }
        }
    }
    
    func fetchMessage(withTripToken tripToken: String) {
        // If presenting messaging vc
        if let messagingVC = HMViewControllerManager.shared.presentingViewController as? HMCustomerMessagingViewController {
            if messagingVC.tripToken == tripToken {
                messagingVC.purgeData()
                messagingVC.loadData()
            } else {
                newMessageAlert(withTripToken: tripToken)
            }
        }
    }
    
    func presentMessagingVC(withTripToken tripToken: String) {
        // Presentable vc
        guard let presentableVC = HMViewControllerManager.shared.getPresentableViewController() else { return }
        
        // Customer token
        HMTrip.getTripDetail(withTripToken: tripToken) { (result, error) in
            DispatchQueue.main.async {
                if let result = result,
                    let customerInfo = result["customer_info"] as? [String : Any],
                    let customerToken = customerInfo["customer_token"] as? String {
                    
                    // Present messaging vc
                    if let messagingNavigationVC = HMViewControllerManager.shared.presentingViewController?.storyboard?.instantiateViewController(withIdentifier: String(describing: HMCustomerMessagingNavigationController.self)) as? HMCustomerMessagingNavigationController {
                        let messagingVC = messagingNavigationVC.viewControllers.first as! HMCustomerMessagingViewController
                        messagingVC.customerToken = customerToken
                        messagingVC.tripToken = tripToken
                        presentableVC.present(messagingNavigationVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
