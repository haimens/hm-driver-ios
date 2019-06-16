import UIKit

class HMAccountViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        // Navigation appearance
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
