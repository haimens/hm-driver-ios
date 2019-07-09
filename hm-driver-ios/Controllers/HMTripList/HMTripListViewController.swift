import UIKit

class HMTripListViewController: UIViewController {
    @IBOutlet weak var segmentedControl: TDSwiftSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // UI Components
    var spinner: TDSwiftSpinner!
    
    // Data
    var activeTripList: [[String : Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDelegates()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupSegmentedControl()
    }
    
    private func setupSegmentedControl() {
        segmentedControl.itemTitles = ["UPCOMING", "HISTORY"]
    }
    
    private func setupUI() {
        // Navigation appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Refresh control
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString.init(string: "Pull to refresh")
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshRequest), for: .valueChanged)
        
        // Spinner
        spinner = TDSwiftSpinner(viewController: self)
    }
    
    private func setupDelegates() {
        segmentedControl.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func handleRefreshRequest() { loadData() }
}

// Data
extension HMTripListViewController: TDSwiftData {
    func loadData() {
        // Show spinner
        spinner.show()
        
        // Make request
        HMTrip.getAllActiveTrips { (result, error) in
            DispatchQueue.main.async {
                // Hide spinner
                self.spinner.hide()
                
                // Dismiss refresh control if is refreshing
                if self.tableView.refreshControl!.isRefreshing {
                    self.tableView.refreshControl!.endRefreshing()
                }
                
                // Hand request error
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: DriverConn.getErrorMessage(error: error), actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                
                // Parse request response
                if let result = result { self.parseData(data: result) }
            }
        }
    }
    
    func parseData(data: [String : Any]) {
        // Record list
        guard let activeTripList = data["record_list"] as? [[String : Any]] else { alertParseDataFailed(); return }
        self.activeTripList = activeTripList
        
        // Reload UI
        tableView.reloadData()
    }
    
    func alertParseDataFailed() {
        TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Server response invalid", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
    }
}

extension HMTripListViewController: TDSwiftSegmentedControlDelegate {
    func itemSelected(atIndex index: Int) {
        print("Item selected: \(index)")
    }
}

extension HMTripListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeTripList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reusable cell instance
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HMTripListTableViewCell.self)) as! HMTripListTableViewCell
        
        // Pickup time
        if let pickupTimeString = activeTripList?[indexPath.row]["pickup_time"] as? String {
            cell.dateLabel.text = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: pickupTimeString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MMM d' - 'h:mm a") ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        } else {
            cell.dateLabel.text = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        }
        
        // From and to address
        let fromAddressString = activeTripList?[indexPath.row]["from_addr_str"] as? String ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        let toAddressString = activeTripList?[indexPath.row]["to_addr_str"] as? String ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        cell.routeDetailView.upperAddressBtn.setTitle(fromAddressString, for: .normal)
        cell.routeDetailView.lowerAddressBtn.setTitle(toAddressString, for: .normal)
        cell.routeDetailView.delegate = self
        
        // Disable cell address buttons
        cell.routeDetailView.upperAddressBtn.isEnabled = false
        cell.routeDetailView.lowerAddressBtn.isEnabled = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Present trip detail VC
        let tripDetailVC = storyboard?.instantiateViewController(withIdentifier: String(describing: HMTripDetailViewController.self)) as! HMTripDetailViewController
        tripDetailVC.tripToken = activeTripList?[indexPath.row]["trip_token"] as? String
        self.navigationController?.pushViewController(tripDetailVC, animated: true)
    }
}

extension HMTripListViewController: TDSwiftRouteDetailViewDelegate {
    func didSelectAddressBtn(atLocation location: TDSwiftRouteDetailViewAddressButtonLocation, button: UIButton) {
        TDSwiftMapTools.showAddressOptions(onViewController: self, withAddress: button.titleLabel?.text ?? "", completion: nil)
    }
}
