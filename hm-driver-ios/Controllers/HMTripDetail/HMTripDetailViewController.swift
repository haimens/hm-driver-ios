import UIKit
import MapKit

enum HMTripDetailType: Int {
    case dispatched = 3
    case onTheWay = 4
    case arrived = 5
    case cob = 6
    case cad = 7
    
    static func getType(withStatus status: Int) -> HMTripDetailType? {
        switch status {
        case 3:
            return .dispatched
        case 4:
            return .onTheWay
        case 5:
            return .arrived
        case 6:
            return .cob
        case 7:
            return .cad
        default:
            return nil
        }
    }
}

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
    var currentTripDetailType: HMTripDetailType?
    
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
        
        // Current sharing location button title
        var sharingLocationButtonTitle = ""
        switch TDSwiftHeartBeat.shared.getHeartBeatStatus() {
        case .activated:
            sharingLocationButtonTitle = "Sharing Location (ON)"
        case .terminated:
            sharingLocationButtonTitle = "Sharing Location"
        }
        popover.items[3] = TDSwiftPopoverItem(iconImage: popover.items[3].iconImage, titleText: sharingLocationButtonTitle)
        
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
        // Trip detail type
        if let status = (data["basic_info"] as? [String : Any])?["status"] as? Int {
            // Parse status
            currentTripDetailType = HMTripDetailType.getType(withStatus: status)
        }
        
        // Verify trip detail type
        guard let currentTripDetailType = currentTripDetailType else {
            TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Invalid trip status", actionBtnTitle: "OK", presentVC: self) {
                // Diamiss current vc, trip status invalid
                self.navigationController?.popViewController(animated: true)
                return
            }
            return
        }
        
        
        // VC title date
        if let pickupTimeString = (data["basic_info"] as? [String : Any])?["pickup_time"] as? String {
            self.title = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: pickupTimeString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MMM d") ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        } else {
            self.title = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        }
        
        // Coordinate
        // Pickup, dropoff location and pickup time
        if let pickupLat = (data["from_address_info"] as? [String : Any])?["lat"] as? Double,
            let pickupLng = (data["from_address_info"] as? [String : Any])?["lng"] as? Double,
            let dropoffLat = (data["to_address_info"] as? [String : Any])?["lat"] as? Double,
            let dropoffLng = (data["to_address_info"] as? [String : Any])?["lng"] as? Double,
            let utcPickupTimeString = (data["basic_info"] as? [String : Any])?["pickup_time"] as? String,
            let pickupTimeString = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: utcPickupTimeString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "h:mm a") {
            switch currentTripDetailType {
            case .dispatched, .onTheWay:
                // Current location
                let currentCoordinate = HMLocationManager.shared.locationManager.location?.coordinate
                if currentCoordinate == nil { TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "Your location is temporarily unavailable", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                let currentLocation = CLLocation(latitude: currentCoordinate!.latitude, longitude: currentCoordinate!.longitude)
                
                // Config mapview
                mapView.showsUserLocation = true
                mapView.config(config: TDSwiftRouteDetailMapView.defaultConfig,
                               info: TDSwiftRouteDetailMapViewInfo(sourceTitle: "Driver Location",
                                                                   destinationTitle: "Pickup \(pickupTimeString)",
                                sourceLocation: currentLocation,
                                destinationLocation: CLLocation(latitude: pickupLat, longitude: pickupLng)))
                mapView.drawRoute(removeOldRoute: true, completion: nil)
            case .arrived:
                // ConfigM mapview
                mapView.showsUserLocation = false
                mapView.config(config: TDSwiftRouteDetailMapView.defaultConfig,
                               info: TDSwiftRouteDetailMapViewInfo(sourceTitle: "Pickup \(pickupTimeString)",
                                destinationTitle: "Dropoff",
                                sourceLocation: CLLocation(latitude: pickupLat, longitude: pickupLng),
                                destinationLocation: CLLocation(latitude: dropoffLat, longitude: dropoffLng)))
                mapView.drawRoute(removeOldRoute: true, completion: nil)
            case .cob:
                // ConfigM mapview
                mapView.showsUserLocation = false
                mapView.config(config: TDSwiftRouteDetailMapView.defaultConfig,
                               info: TDSwiftRouteDetailMapViewInfo(sourceTitle: "Customer On Board",
                                                                   destinationTitle: "Dropoff",
                                                                   sourceLocation: CLLocation(latitude: pickupLat, longitude: pickupLng),
                                                                   destinationLocation: CLLocation(latitude: dropoffLat, longitude: dropoffLng)))
                mapView.drawRoute(removeOldRoute: true, completion: nil)
            case .cad:
                // Cad time
                if let utcCadTimeString = (data["basic_info"] as? [String : Any])?["cad_time"] as? String,
                    let cadTimeString = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: utcCadTimeString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "h:mm a"){
                    // ConfigM mapview
                    mapView.showsUserLocation = false
                    mapView.config(config: TDSwiftRouteDetailMapView.defaultConfig,
                                   info: TDSwiftRouteDetailMapViewInfo(sourceTitle: "Pickup \(pickupTimeString)",
                                                                       destinationTitle: "Dropoff \(cadTimeString)",
                                                                       sourceLocation: CLLocation(latitude: pickupLat, longitude: pickupLng),
                                                                       destinationLocation: CLLocation(latitude: dropoffLat, longitude: dropoffLng)))
                    mapView.drawRoute(removeOldRoute: true, completion: nil)
                } else {
                    TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "CAD time not found", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                }
            }
        } else {
            TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "Location info unavailable", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
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
