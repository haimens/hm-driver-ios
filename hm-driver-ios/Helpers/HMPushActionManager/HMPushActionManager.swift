import Foundation
import UIKit

enum HMPushActionType {
    case locationSharing
    case fetchSMS(customerToken: String)
    
    func getCustomerToken() -> String? {
        switch self {
        case let .fetchSMS(customerToken: token):
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
                if let customerToken = initAction.getCustomerToken() {
                    presentMessagingVC(withCustomerToken: customerToken)
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
    
    func newMessageAlert(withCustomerToken customerToken: String) {
        if let presentingVC = HMViewControllerManager.shared.presentingViewController {
            TDSwiftAlert.showSingleButtonAlertWithCancel(title: "Message Center", message: "You've received a new message, view now?", actionBtnTitle: "View", cancelBtnTitle: "Cancel", presentVC: presentingVC) {
                self.presentMessagingVC(withCustomerToken: customerToken)
            }
        }
    }
    
    func fetchMessage(withCustomerToken customerToken: String) {
        // If presenting messaging vc
        if let messagingVC = HMViewControllerManager.shared.presentingViewController as? HMCustomerMessagingViewController {
            if messagingVC.customerToken == customerToken {
                messagingVC.purgeData()
                messagingVC.loadData()
            } else {
                newMessageAlert(withCustomerToken: customerToken)
            }
        }
    }
    
    func presentMessagingVC(withCustomerToken customerToken: String) {
        // Presentable vc
        guard let presentableVC = HMViewControllerManager.shared.getPresentableViewController() else { return }
        
        // Present messaging vc
        if let messagingNavigationVC = HMViewControllerManager.shared.presentingViewController?.storyboard?.instantiateViewController(withIdentifier: String(describing: HMCustomerMessagingNavigationController.self)) as? HMCustomerMessagingNavigationController {
            let messagingVC = messagingNavigationVC.viewControllers.first as! HMCustomerMessagingViewController
            messagingVC.customerToken = customerToken
            presentableVC.present(messagingNavigationVC, animated: true, completion: nil)
        }
    }
}
