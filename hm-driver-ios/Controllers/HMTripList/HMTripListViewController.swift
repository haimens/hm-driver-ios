import UIKit

class HMTripListViewController: UIViewController {
    @IBOutlet weak var mainSegmentedControl: TDSwiftSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup
        setupUI()
        setupDelegates()
    }
    
    private func setupUI() {
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
