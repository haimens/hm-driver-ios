import UIKit

enum HMTripListType {
    case upcoming
    case history
}

class HMTripListViewController: UIViewController {
    @IBOutlet weak var segmentedControl: TDSwiftSegmentedControl!
    @IBOutlet weak var tableView: TDSwiftInfiniteTableView!
    
    // UI Components
    var spinner: TDSwiftSpinner!
    
    // Segmented control data
    var tripListItemPosition: [HMTripListType]!
    var currentTripListType: HMTripListType = .upcoming
    
    // Active trip list data
    var activeTripList: [[String : Any]]?
    var activeTripListEnd: Int?
    var activeTripListCount: Int?
    
    // History trip list data
    var historyTripList: [[String : Any]]?
    var historyTripListEnd: Int?
    var historyTripListCount: Int?
    
    // Current trip list data
    var currentTripList: [[String : Any]]? {
        get {
            switch currentTripListType {
            case .upcoming:
                return activeTripList
            case .history:
                return historyTripList
            }
        }
        set {
            switch currentTripListType {
            case .upcoming:
                activeTripList = newValue
            case .history:
                historyTripList = newValue
            }
        }
    }
    var currentTripListEnd: Int? {
        get {
            switch currentTripListType {
            case .upcoming:
                return activeTripListEnd
            case .history:
                return historyTripListEnd
            }
        }
        set {
            switch currentTripListType {
            case .upcoming:
                activeTripListEnd = newValue
            case .history:
                historyTripListEnd = newValue
            }
            
        }
    }
    var currentTripListCount: Int? {
        get {
            switch currentTripListType {
            case .upcoming:
                return activeTripListCount
            case .history:
                return historyTripListCount
            }
        }
        set {
            switch currentTripListType {
            case .upcoming:
                activeTripListCount = newValue
            case .history:
                historyTripListCount = newValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDelegates()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Navigation bar appearance
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupSegmentedControl()
    }
    
    private func setupSegmentedControl() {
        segmentedControl.itemTitles = ["UPCOMING", "HISTORY"]
        tripListItemPosition = [.upcoming, .history]
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
    
    @objc func handleRefreshRequest() { purgeData(); loadData() }
    
    func animateTableView(toState state: TDSwiftInfiniteTableViewState) {
        switch state {
        case .loading:
            // Footer spinner
            tableView.isLoadingNewContent = true
            
            // Show spinner
            spinner.show()
        case .standBy:
            // Disable footer spinner
            self.tableView.isLoadingNewContent = false
            
            // Hide spinner
            self.spinner.hide()
            
            // Dismiss refresh control if is refreshing
            if let refreshControl = self.tableView.refreshControl, refreshControl.isRefreshing {
                self.tableView.refreshControl!.endRefreshing()
            }
        }
    }
}

// Data
extension HMTripListViewController: TDSwiftData {
    func loadData() {
        // Animate table view
        animateTableView(toState: .loading)
        
        // Make request
        switch currentTripListType {
        case .upcoming:
            HMTrip.getAllActiveTrips(query: ["start": String(describing: activeTripListEnd ?? 0), "order_key": "udate", "order_direction": "ASC"]) { (result, error) in
                DispatchQueue.main.async {
                    // Hand request error
                    if let error = error {
                        TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: DriverConn.getErrorMessage(error: error), actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                        self.animateTableView(toState: .standBy)
                    }
                    
                    // Parse request response
                    if let result = result { self.parseData(data: result) }
                }
            }
        case .history:
            HMTrip.getAllTrips(query: ["status": 8, "start": String(describing: historyTripListEnd ?? 0), "order_key": "udate", "order_direction": "DESC"]) { (result, error) in
                DispatchQueue.main.async {
                    // Hand request error
                    if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: DriverConn.getErrorMessage(error: error), actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                    
                    // Parse request response
                    if let result = result { self.parseData(data: result) }
                }
            }
        }
    }
    
    func parseData(data: [String : Any]) {
        // Record list
        guard let end = data["end"] as? Int,
            let count = data["count"] as? Int,
            let tripList = data["record_list"] as? [[String : Any]] else { alertParseDataFailed(); return }
        
        // Assign parsed data to variable
        self.currentTripList == nil ? self.currentTripList = tripList : self.currentTripList?.append(contentsOf: tripList)
        self.currentTripListEnd = end
        self.currentTripListCount = count
        
        // Animate table view
        animateTableView(toState: .standBy)
        
        // Reload UI
        tableView.reloadData()
    }
    
    func purgeData() {
        self.currentTripList = nil
        self.currentTripListEnd = nil
        self.currentTripListCount = nil
    }
    
    func alertParseDataFailed() {
        TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Server response invalid", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
    }
}

extension HMTripListViewController: TDSwiftSegmentedControlDelegate {
    func itemSelected(atIndex index: Int) {
        // Update currentTripListType
        currentTripListType = tripListItemPosition[index]
        
        // Load data if not found, otherwise reload UI
        if currentTripList == nil {
            loadData()
        } else {
            self.tableView.reloadData()
        }
    }
}

extension HMTripListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTripList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reusable cell instance
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HMTripListTableViewCell.self)) as! HMTripListTableViewCell
        
        // Pickup time
        if let pickupTimeString = currentTripList?[indexPath.row]["pickup_time"] as? String {
            cell.dateLabel.text = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: pickupTimeString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MMM d' - 'h:mm a") ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        } else {
            cell.dateLabel.text = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        }
        
        // From and to address
        let fromAddressString = currentTripList?[indexPath.row]["from_addr_str"] as? String ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        let toAddressString = currentTripList?[indexPath.row]["to_addr_str"] as? String ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
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
        
        // Present trip detail VC if showing active trip list
        if currentTripListType == .upcoming {
            let tripDetailVC = storyboard?.instantiateViewController(withIdentifier: String(describing: HMTripDetailViewController.self)) as! HMTripDetailViewController
            tripDetailVC.tripToken = activeTripList?[indexPath.row]["trip_token"] as? String
            self.navigationController?.pushViewController(tripDetailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let currentListLength = self.currentTripList?.count ?? 0
        if let currentTripListCount = currentTripListCount, indexPath.row == (currentListLength - 1) {
            if currentTripListCount > currentListLength {
                loadData()
            }
        }
    }
    
}

extension HMTripListViewController: TDSwiftRouteDetailViewDelegate {
    func didSelectAddressBtn(atLocation location: TDSwiftRouteDetailViewAddressButtonLocation, button: UIButton) {
        TDSwiftMapTools.showAddressOptions(onViewController: self, withAddress: button.titleLabel?.text ?? "", completion: nil)
    }
}
