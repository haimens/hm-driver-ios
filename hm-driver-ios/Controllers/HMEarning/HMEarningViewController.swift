import UIKit

class HMEarningViewController: UIViewController {
    @IBOutlet weak var segmentedControl: TDSwiftSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
//    // Table data
//    let earningList: [String] = ["Hi", "Hi", "Hi", "Hi", "Hi", "Hi", "Hi", "Hi", "Hi", "Hi"]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupUI()
//        setupDelegates()
//    }
//    
//    private func setupUI() {
//        // Navigation appearance
//        navigationController?.navigationBar.prefersLargeTitles = true
//    
//        // Segmented control
//        segmentedControl.itemTitles = ["WAGE", "SALARY"]
//        
//        // Refresh control
//        tableView.refreshControl = UIRefreshControl()
//        tableView.refreshControl?.attributedTitle = NSAttributedString.init(string: "Pull to refresh")
//        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshRequest), for: .valueChanged)
//    }
//
//    private func setupDelegates() {
//        segmentedControl.delegate = self
//        tableView.delegate = self
//        tableView.dataSource = self
//    }
//    
//    @objc func handleRefreshRequest() {
//        // Update your content…
//        
//        // Dismiss the refresh control.
//        DispatchQueue.main.async {
//            self.tableView.refreshControl?.endRefreshing()
//        }
//    }

}

//extension HMEarningViewController: TDSwiftSegmentedControlDelegate {
//    func itemSelected(atIndex index: Int) {
//        print("Item selected: \(index)")
//    }
//}
//
//extension HMEarningViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return earningList.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HMEarningWageTableViewCell.self)) as! HMEarningWageTableViewCell
//
//        cell.setValues()
//
//        return cell
//    }
//}
