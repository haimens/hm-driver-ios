import Foundation
import UIKit

class HMViewControllerManager {
    // Singleton instance
    private init() {}
    static let shared = HMViewControllerManager()
    
    // Current presenting view controller
    weak var presentingViewController: UIViewController?
}
