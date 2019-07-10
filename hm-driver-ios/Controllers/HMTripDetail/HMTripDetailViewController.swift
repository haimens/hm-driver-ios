import UIKit
import MapKit

class HMTripDetailViewController: UIViewController {
    // UI Components
    var popover: TDSwiftPopover!
    var spinner: TDSwiftSpinner!
    
    @IBOutlet weak var mapView: TDSwiftRouteDetailMapView!
    @IBOutlet weak var routeDetailView: HMRouteDetailView!
    @IBOutlet weak var specialInstructionBtn: UIButton!
    
    @IBAction func specialInstructionBtnClicked(_ sender: UIButton) {
        // Show note if available
        if let note = specialInstructionString {
            TDSwiftAlert.showSingleButtonAlert(title: "Special Instruction", message: note, actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        }
    }
    
    // Data
    var tripToken: String?
    var specialInstructionString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDelegate()
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
    
    private func setupDelegate() {
        routeDetailView.delegate = self
    }
    
    @objc private func showOptionsMenu(_ sender: UIBarButtonItem) {
        // Calculate popover origin
        let buttonItemView = self.navigationItem.rightBarButtonItem!.value(forKey: "view") as! UIView
        let buttonItemViewCenter = buttonItemView.convert(buttonItemView.center, to: self.view)
        let popoverOrigin = CGPoint(x: buttonItemViewCenter.x - 5, y: buttonItemViewCenter.y + 10)
        
        // Present popover
        popover.present(onView: self.navigationController!.view, atPoint: popoverOrigin)
    }
    
    private func configNavigationAppearance() { navigationController?.navigationBar.prefersLargeTitles = false }
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
                // Hand request error
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: DriverConn.getErrorMessage(error: error), actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                
                // Parse request response
                if let result = result { self.parseData(data: result) }
            }
        }
    }
    
    func parseData(data: [String : Any]) {
        // VC title date
        if let pickupTimeString = (data["basic_info"] as? [String : Any])?["pickup_time"] as? String {
            self.title = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: pickupTimeString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MMM d") ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        } else {
            self.title = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        }
        
        // Coordinate
        if let fromLat = (data["from_address_info"] as? [String : Any])?["lat"] as? Double,
            let fromLng = (data["from_address_info"] as? [String : Any])?["lng"] as? Double,
            let toLat = (data["to_address_info"] as? [String : Any])?["lat"] as? Double,
            let toLng = (data["to_address_info"] as? [String : Any])?["lng"] as? Double {
            mapView.config(config: TDSwiftRouteDetailMapView.defaultConfig,
                           info: TDSwiftRouteDetailMapViewInfo(sourceTitle: "Driver Location",
                                                               destinationTitle: "Pickup",
                                                               sourceLocation: CLLocation(latitude: fromLat, longitude: fromLng),
                                                               destinationLocation: CLLocation(latitude: toLat, longitude: toLng)))
            mapView.drawRoute(removeOldRoute: true, completion: nil)
        }
        
        // From, to address
        if let fromAddressString = (data["from_address_info"] as? [String : Any])?["addr_str"] as? String {
            routeDetailView.upperAddressBtn.setTitle(fromAddressString, for: .normal)
        }
        if let toAddressString = (data["to_address_info"] as? [String : Any])?["addr_str"] as? String {
            routeDetailView.lowerAddressBtn.setTitle(toAddressString, for: .normal)
        }

        // Special instruction
        if let note = (data["basic_info"] as? [String : Any])?["note"] as? String {
            specialInstructionBtn.isEnabled = true
            specialInstructionString = note
        } else {
            specialInstructionBtn.isEnabled = false
        }
        
        // Hide spinner
        self.spinner.hide()
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

extension HMTripDetailViewController: TDSwiftRouteDetailViewDelegate {
    func didSelectAddressBtn(atLocation location: TDSwiftRouteDetailViewAddressButtonLocation, button: UIButton) {
        TDSwiftMapTools.showAddressOptions(onViewController: self, withAddress: button.titleLabel?.text ?? "", completion: nil)
    }
}
