import UIKit

class HMPersonalInfoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configNavigationAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configNavigationAppearance()
    }
    
    private func configNavigationAppearance() { navigationController?.navigationBar.prefersLargeTitles = false }
}
