import UIKit

enum HMEarningListType {
    case wage
    case salary
}

class HMEarningViewController: UIViewController {
    @IBOutlet weak var segmentedControl: TDSwiftSegmentedControl!
    @IBOutlet weak var tableView: TDSwiftInfiniteTableView!
    
    // UI Components
    var spinner: TDSwiftSpinner!
    
    // Segmented control data
    var earningListItemPosition: [HMEarningListType]!
    var currentEarningListType: HMEarningListType = .wage
    
    // Wage list data
    var wageList: [[String : Any]]?
    var wageListEnd: Int?
    var wageListCount: Int?
    
    // Salary list data
    var salaryList: [[String : Any]]?
    var salaryListEnd: Int?
    var salaryListCount: Int?
    
    // Current earning list data
    var currentEarningList: [[String : Any]]? {
        get {
            switch currentEarningListType {
            case .wage:
                return wageList
            case .salary:
                return salaryList
            }
        }
        set {
            switch currentEarningListType {
            case .wage:
                wageList = newValue
            case .salary:
                salaryList = newValue
            }
        }
    }
    var currentEarningListEnd: Int? {
        get {
            switch currentEarningListType {
            case .wage:
                return wageListEnd
            case .salary:
                return salaryListEnd
            }
        }
        set {
            switch currentEarningListType {
            case .wage:
                wageListEnd = newValue
            case .salary:
                salaryListEnd = newValue
            }
            
        }
    }
    var currentEarningListCount: Int? {
        get {
            switch currentEarningListType {
            case .wage:
                return wageListCount
            case .salary:
                return salaryListCount
            }
        }
        set {
            switch currentEarningListType {
            case .wage:
                wageListCount = newValue
            case .salary:
                salaryListCount = newValue
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
        segmentedControl.itemTitles = ["TRANSACTION", "EARNING"]
        earningListItemPosition = [.wage, .salary]
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
extension HMEarningViewController: TDSwiftData {
    func loadData() {
        // Animate table view
        animateTableView(toState: .loading)
        
        // Make request
        switch currentEarningListType {
        case .wage:
            HMWage.getAllWages(query: ["start": String(describing: wageListEnd ?? 0), "order_key": "udate", "order_direction": "DESC"]) { (result, error) in
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
        case .salary:
            HMSalary.getAllSalaries(query: ["start": String(describing: salaryListEnd ?? 0), "order_key": "udate", "order_direction": "DESC"]) { (result, error) in
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
            let earningList = data["record_list"] as? [[String : Any]] else { alertParseDataFailed(); return }
        
        // Assign parsed data to variable
        self.currentEarningList == nil ? self.currentEarningList = earningList : self.currentEarningList?.append(contentsOf: earningList)
        self.currentEarningListEnd = end
        self.currentEarningListCount = count
        
        // Animate table view
        animateTableView(toState: .standBy)
        
        // Reload UI
        tableView.reloadData()
    }
    
    func purgeData() {
        self.currentEarningList = nil
        self.currentEarningListEnd = nil
        self.currentEarningListCount = nil
    }
    
    func alertParseDataFailed() {
        TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Server response invalid", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
    }
}

extension HMEarningViewController: TDSwiftSegmentedControlDelegate {
    func itemSelected(atIndex index: Int) {
        // Update currentTripListType
        currentEarningListType = earningListItemPosition[index]
        
        // VC title
        switch currentEarningListType {
        case .wage:
            self.navigationItem.title = "Transaction"
        case .salary:
            self.navigationItem.title = "Earning"
        }
        
        // Load data if not found, otherwise reload UI
        if currentEarningList == nil {
            loadData()
        } else {
            self.tableView.reloadData()
        }
    }
}

extension HMEarningViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentEarningList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentEarningListType {
        case .wage:
            // Cell instance
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HMEarningWageTableViewCell.self)) as! HMEarningWageTableViewCell
            
            // Date time
            var dateTimeString = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
            if let utcDateTimeString = currentEarningList?[indexPath.row]["udate"] as? String {
                dateTimeString = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: utcDateTimeString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MMM d' - 'h:mm a") ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
            }
            
            // Wage type
            var wageType:HMEarningWageType = .UNKNOWN
            if let rawWageType = currentEarningList?[indexPath.row]["type"] as? Int {
                switch rawWageType {
                case 1:
                    wageType = .IN
                case 2:
                    wageType = .OUT
                default:
                    wageType = .UNKNOWN
                }
            }
            
            // Note
            var note = ""
            if let rawNote = currentEarningList?[indexPath.row]["note"] as? String {
                note = rawNote
            }
            
            // Amount
            var amountInDollarString = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
            if let amountInCent = currentEarningList?[indexPath.row]["amount"] as? Int {
                amountInDollarString = "$\(HMMoneyUnitConverter.centToDollar(amountInCent: amountInCent))"
            }
            
            // Update cell UI
            cell.setValues(type: wageType, dateTimeString: dateTimeString, subtitleString: note, amountString: amountInDollarString)
            
            return cell
        case .salary:
            // Cell instance
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HMEarningSalaryTableViewCell.self)) as! HMEarningSalaryTableViewCell
            
            // Date time
            var dateTimeString = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
            if let utcDateTimeString = currentEarningList?[indexPath.row]["udate"] as? String {
                dateTimeString = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: utcDateTimeString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MMM d' - 'h:mm a") ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
            }

            // Receipt
            var receipt = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
            if let rawReceipt = currentEarningList?[indexPath.row]["receipt"] as? String {
                receipt = rawReceipt
            }
            
            // Amount
            var amountInDollarString = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
            if let amountInCent = currentEarningList?[indexPath.row]["amount"] as? Int {
                amountInDollarString = "$\(HMMoneyUnitConverter.centToDollar(amountInCent: amountInCent))"
            }
            
            // Update cell UI
            cell.setValues(dateTimeString: dateTimeString, subtitleString: receipt, amountString: amountInDollarString)
            
            return cell
        }        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let currentListLength = self.currentEarningList?.count ?? 0
        if let currentEarningListCount = currentEarningListCount, indexPath.row == (currentListLength - 1) {
            if currentEarningListCount > currentListLength {
                loadData()
            }
        }
    }
}
