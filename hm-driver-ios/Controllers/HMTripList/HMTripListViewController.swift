import UIKit

class HMTripListViewController: UIViewController {
    @IBOutlet weak var mainSegmentedControl: TDSwiftSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupUI()
    }
    
    private func setupUI() {
        // Navigation appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Segmented control
        mainSegmentedControl.itemTitles = ["UPCOMING", "HISTORY"]
    }
    
    private func setupDelegates() {
        // Segmented control delegate
        mainSegmentedControl.delegate = self
    }
}

extension HMTripListViewController: TDSwiftSegmentedControlDelegate {
    func itemSelected(atIndex index: Int) {
        print("Item selected: \(index)")
    }
}
