import UIKit
import OneSignal

class HMAccountViewController: UITableViewController {
    @IBOutlet weak var sharingLocationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigationAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add presenting vc reference
        HMViewControllerManager.shared.presentingViewController = self
        
        configNavigationAppearance()
        
        updateSharingLocationLabel()
    }
    
    private func configNavigationAppearance() { navigationController?.navigationBar.prefersLargeTitles = true }
    
    private func shouldChangeSharingLocationServiceStatus() -> (Bool, (() -> Void)?) {
        if HMLocationManager.shared.getServiceAuthorizationStatus() == .authorizedAlways {
            return (true, nil)
        } else {
            return (false, { TDSwiftAlert.showSingleButtonAlert(title: "Action Failed", message: "Location service not authorized", actionBtnTitle: "OK", presentVC: self, btnAction: nil) })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect tableview cell
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0: // Personal Information
            performSegue(withIdentifier: String(describing: HMPersonalInfoViewController.self), sender: self)
        case 1: // Reset password
            performSegue(withIdentifier: String(describing: HMResetPasswordViewController.self), sender: self)
        case 2: // Contact dispatch center
            if (HMGlobal.shared.isDispatchCellAvailable()) {
                HMGlobal.shared.callDispatchCenter()
            } else {
                TDSwiftAlert.showSingleButtonAlert(title: "Failed", message: "Dispatch center info missing", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
            }
        case 3: // Sharing Location
            let (shouldAct, showAlert) = self.shouldChangeSharingLocationServiceStatus()
            
            if shouldAct {
                HMHeartBeat.shared.start()
                TDSwiftAlert.showSingleButtonAlert(title: "Location Sharing", message: "Service Started", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                updateSharingLocationLabel()
            } else {
                showAlert?()
            }
        case 4: // Stop Sharing Location
            let (shouldAct, showAlert) = self.shouldChangeSharingLocationServiceStatus()
            
            if shouldAct {
                HMHeartBeat.shared.stop()
                TDSwiftAlert.showSingleButtonAlert(title: "Location Sharing", message: "Service Terminated", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                updateSharingLocationLabel()
            } else {
                showAlert?()
            }
        case 5: // Logout
            // Remove current auth and user info
            TDSwiftHavana.shared.removeAuthInfo()
            TDSwiftHavana.shared.removeUserInfo()
            
            // Remove one signal external user id
            OneSignal.removeExternalUserId()
            
            // Present auth vc
            let authVC = self.storyboard!.instantiateViewController(withIdentifier: String(describing: HMAuthViewController.self))
            self.present(authVC, animated: true, completion: nil)
        default:
            fatalError("Account VC index not implemented")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove presenting vc reference
        HMViewControllerManager.shared.unlinkPresentingViewController(withViewController: self)
    }
    
    func updateSharingLocationLabel() {
        sharingLocationLabel.text = HMHeartBeat.shared.getSharingButtonTitle()
        sharingLocationLabel.textColor = HMHeartBeat.shared.getSharingButtonColor()
    }
}
