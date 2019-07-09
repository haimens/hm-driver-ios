import UIKit

class HMTripDetailViewController: UIViewController {
    // UI Components
    var popover: TDSwiftPopover!
    var spinner: TDSwiftSpinner!
    
    // Data
    var tripToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) { configNavigationAppearance() }
    
    override func viewWillDisappear(_ animated: Bool) { popover.dismiss() }
    
    private func setupUI() {
        // Navigation appearance
        configNavigationAppearance()
        
        // Menu bar button
        navigationItem.rightBarButtonItem = HMThreeDotsBarButtonItem(target: self, selector: #selector(self.showOptionsMenu(_:)))
        
        // Popover menu
        popover = HMTripDetailPopover()
        popover.delegate = self
        
        // Spinner
        spinner = TDSwiftSpinner(viewController: self)
    }
    
    @objc private func showOptionsMenu(_ sender: UIBarButtonItem) {
        // Calculate popover origin
        let buttonItemView = self.navigationItem.rightBarButtonItem!.value(forKey: "view") as! UIView
        let buttonItemViewCenter = buttonItemView.convert(buttonItemView.center, to: self.view)
        let popoverOrigin = CGPoint(x: buttonItemViewCenter.x - 5, y: buttonItemViewCenter.y + 10)
        
        // Present popover
        popover.present(onView: self.navigationController!.view, atPoint: popoverOrigin)
    }
    
    private func configNavigationAppearance() {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}

extension HMTripDetailViewController: TDSwiftData {
    func loadData() {
        // Verify trip token
        guard let tripToken = self.tripToken else { TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Trip detail missing", actionBtnTitle: "OK", presentVC: self, btnAction: nil); return }
        
        // Show spinner
        spinner.show()
        
        // Make request
        HMTrip.getTripDetail(withTripToken: tripToken) { (result, error) in
            DispatchQueue.main.async {
                // Hide spinner
                self.spinner.hide()
                
                // Hand request error
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: DriverConn.getErrorMessage(error: error), actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                
                // Parse request response
                if let result = result { self.parseData(data: result) }
            }
        }
    }
    
    func parseData(data: [String : Any]) {
        // !!!!!!!!!TODO!!!!!!!!!!!!!!!!!!
        print("Data \(data)")
    }
    
    func alertParseDataFailed() {
        TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Server response invalid", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
    }
}

extension HMTripDetailViewController: TDSwiftPopoverDelegate {
    func didSelect(item: TDSwiftPopoverItem, atIndex index: Int) {
        switch index {
        case 3: // Sharing Location
            HMHeartBeat.shared.start()
            TDSwiftAlert.showSingleButtonAlert(title: "Location Sharing", message: "Service Started", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        case 4: // Stop Sharing Location
            HMHeartBeat.shared.stop()
            TDSwiftAlert.showSingleButtonAlert(title: "Location Sharing", message: "Service Terminated", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        default:
            fatalError("TRIP DETAIL POPOVER INDEX INVALID")
        }
    }
}
