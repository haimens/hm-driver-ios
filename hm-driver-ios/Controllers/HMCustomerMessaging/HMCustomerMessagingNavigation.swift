import Foundation
import UIKit

class HMCustomerMessagingNavigationController: UINavigationController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add presenting vc reference
        HMViewControllerManager.shared.presentingViewController = self
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove presenting vc reference
        HMViewControllerManager.shared.unlinkPresentingViewController(withViewController: self)
    }
}
