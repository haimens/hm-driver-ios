import UIKit

class HMMainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add presenting vc reference
        HMViewControllerManager.shared.presentingViewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check for init push actions
        HMPushActionManager.shared.runInitAction()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove presenting vc reference
        HMViewControllerManager.shared.presentingViewController = nil
    }
}
