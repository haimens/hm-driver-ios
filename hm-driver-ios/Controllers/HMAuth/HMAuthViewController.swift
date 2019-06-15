import UIKit

class HMAuthViewController: UIViewController {
    @IBAction func logoutBtnClicked(_ sender: UIButton) {
        // Remove auth and login info
        TDSwiftHavana.shared.removeAuthInfo()
        TDSwiftHavana.shared.removeUserInfo()
        
        // Present auth vc
//        let authVC = self.storyboard!.instantiateViewController(withIdentifier: String(describing: HMAuthViewController.self))
//        self.present(authVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
