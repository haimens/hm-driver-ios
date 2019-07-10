import UIKit

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
        verifyAuthInfo()
    }
    
    private func verifyAuthInfo() {
        self.performSegue(withIdentifier: String(describing: HMMainTabBarController.self), sender: self)
        
//        // Check user info availability
//        if (TDSwiftHavana.shared.userInfoAvailable()) {
//            TDSwiftHavana.shared.renewAuthInfo { (result, error) in
//                if (result) {
//                    DispatchQueue.main.async {
//                        // Present main view
//                        self.performSegue(withIdentifier: String(describing: HMMainTabBarController.self), sender: self)
//                    }
//                } else {
//                    // Handle login error
//                    if let error = error {
//                        TDSwiftAlert.showSingleButtonAlertWithCancel(title: "Login Failed", message: TDSwiftHavana.getErrorMessage(error: error), actionBtnTitle: "Retry", cancelBtnTitle: "Cancel", presentVC: self, btnAction: { self.verifyAuthInfo() })
//                    }
//                }
//            }
//        } else {
//            // Present login vc, request user info
//            self.performSegue(withIdentifier: String(describing: HMLoginViewController.self), sender: self)
//        }
    }
    
    private func configHeartBeat() {
        
    }
}
