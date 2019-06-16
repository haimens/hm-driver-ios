import UIKit

class HMTripListViewController: UIViewController {
    @IBOutlet weak var mainSegmentedControl: TDSwiftSegmentedControl!
    @IBOutlet weak var mainTableView: UITableView!
    
    // Data
    let testTripList: [[String:String]] = [
        ["date": "June 10th - 12:30 PM", "pickup": "123 One Punch Blvd, Los Angeles, CA 91000", "dropoff": "100 World Way, Los Angeles, CA 91100"],
        ["date": "June 10th - 12:30 PM", "pickup": "123 One Punch Blvd, Los Angeles, CA 91000", "dropoff": "100 World Way, Los Angeles, CA 91100"],
        ["date": "June 10th - 12:30 PM", "pickup": "123 One Punch Blvd, Los Angeles, CA 91000", "dropoff": "100 World Way, Los Angeles, CA 91100"],
        ["date": "June 10th - 12:30 PM", "pickup": "123 One Punch Blvd, Los Angeles, CA 91000", "dropoff": "100 World Way, Los Angeles, CA 91100"],
        ["date": "June 10th - 12:30 PM", "pickup": "123 One Punch Blvd, Los Angeles, CA 91000", "dropoff": "100 World Way, Los Angeles, CA 91100"],
        ["date": "June 10th - 12:30 PM", "pickup": "123 One Punch Blvd, Los Angeles, CA 91000", "dropoff": "100 World Way, Los Angeles, CA 91100"],
        ["date": "June 10th - 12:30 PM", "pickup": "123 One Punch Blvd, Los Angeles, CA 91000", "dropoff": "100 World Way, Los Angeles, CA 91100"]
    ]
    
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
        return testTripList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: String(describing: HMTripListTableViewCell.self)) as! HMTripListTableViewCell
        
        cell.dateLabel.text = testTripList[indexPath.row]["date"]
        cell.routeDetailView.upperAddressBtn.setTitle(testTripList[indexPath.row]["pickup"], for: .normal)
        cell.routeDetailView.lowerAddressBtn.setTitle(testTripList[indexPath.row]["dropoff"], for: .normal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
