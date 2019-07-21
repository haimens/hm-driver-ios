import UIKit
import OneSignal

class HMAuthViewController: UIViewController {
    @IBAction func logoutBtnClicked(_ sender: UIButton) {
        // Remove auth and login info
        TDSwiftHavana.shared.removeAuthInfo()
        TDSwiftHavana.shared.removeUserInfo()
        
        // Present login vc, request user info
        self.performSegue(withIdentifier: String(describing: HMLoginViewController.self), sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If current location service permission is not desired, popup location permission vc
        if HMLocationManager.shared.getServiceAuthorizationStatus() == .authorizedAlways {
            verifyAuthInfo()
        } else {
            self.present(storyboard!.instantiateViewController(withIdentifier: String(describing: HMLocationServicePermissionViewController.self)), animated: true, completion: nil)
        }
    }
    
    private func verifyAuthInfo() {
        // Check user info availability
        if (TDSwiftHavana.shared.userInfoAvailable()) {
            TDSwiftHavana.shared.renewAuthInfo { (result, error) in
                if (result) {
                    DispatchQueue.main.async {
                        // Update global data
                        HMGlobal.shared.makeGlobalRequest()
                        
                        // Update one signal player key
                        self.updatePlayerKey()
                        
                        // Present main view
                        self.performSegue(withIdentifier: String(describing: HMMainTabBarController.self), sender: self)
                    }
                } else {
                    // Handle login error
                    if let error = error {
                        TDSwiftAlert.showSingleButtonAlertWithCancel(title: "Login Failed", message: TDSwiftHavana.getErrorMessage(error: error), actionBtnTitle: "Retry", cancelBtnTitle: "Cancel", presentVC: self, btnAction: { self.verifyAuthInfo() })
                    }
                }
            }
        } else {
            // Present login vc, request user info
            self.performSegue(withIdentifier: String(describing: HMLoginViewController.self), sender: self)
        }
    }
    
    private func updatePlayerKey() {
        // Update driver player key if player id available
        if let playerKey = OneSignal.getPermissionSubscriptionState()?.subscriptionStatus.userId {
//            HMDriver.modifyDriverDetail(body: ["player_key": playerKey], completion: nil)
            HMDriver.modifyDriverDetail(body: ["player_key": playerKey]) { (result, error) in
                print("Update player key result!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                print("result \(result)")
                print("error \(error)")
                print("Update player key result!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add presenting vc reference
        HMViewControllerManager.shared.presentingViewController = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove presenting vc reference
        HMViewControllerManager.shared.presentingViewController = nil
    }
}
