import Foundation
import UIKit

class HMViewControllerManager {
    // Singleton instance
    private init() {}
    static let shared = HMViewControllerManager()
    
    // Current presenting view controller
    weak var presentingViewController: UIViewController? {
        didSet {
            print("presentingViewController \(presentingViewController.self)")
        }
    }
    
    func unlinkPresentingViewController(withViewController viewController: UIViewController) {        
        // If presentingViewController available
        if let presentingViewController = self.presentingViewController {
            // If type different, return
            if presentingViewController.self == viewController.self {
                self.presentingViewController = nil
            }
        }
    }
    
    // Find presentable view controller
    func getPresentableViewController() -> UIViewController? {
        // Presenting view controller
        guard let presentingViewController = presentingViewController else { return nil }
        
        // Navigation vc
        if let navigationVC = presentingViewController as? UINavigationController {
            return navigationVC.topViewController
        }
        
        // Tab bar vc
        if let tabBarVC = presentingViewController as? UITabBarController {
            return tabBarVC.selectedViewController
        }
        
        // Presented vc
        if let presentedVC = presentingViewController.presentedViewController {
            return presentedVC
        }
        
        // Current vc
        return presentingViewController
    }
}
