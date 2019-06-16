import UIKit

class HMTripListViewController: UIViewController {
    @IBOutlet weak var mainSegmentedControl: TDSwiftSegmentedControl!
    @IBOutlet weak var mainTableView: UITableView!
    
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
        mainSegmentedControl.delegate = self
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
}

extension HMTripListViewController: TDSwiftSegmentedControlDelegate {
    func itemSelected(atIndex index: Int) {
        print("Item selected: \(index)")
    }
}

extension HMTripListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: String(describing: HMTripListTableViewCell.self)) as! HMTripListTableViewCell
        return cell
    }
}
