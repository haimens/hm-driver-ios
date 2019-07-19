import UIKit
import MapKit

struct HMActionInfo {
    let title: String
    let description: String
}

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
    
    let currentLocationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: TDSwiftRouteDetailMapView!
    @IBOutlet weak var routeDetailView: HMRouteDetailView!
    @IBOutlet weak var specialInstructionBtn: UIButton!
    @IBOutlet weak var routeInfoLabel: UILabel!
    @IBOutlet weak var actionBtn: HMBasicButton!
    @IBOutlet weak var flightInfoBtn: UIButton!
    
    @IBAction func flightInfoBtnClicked(_ sender: UIButton) {
        print(sender.titleLabel?.text)
    }
    
    @IBAction func specialInstructionBtnClicked(_ sender: UIButton) {
        // Show note if available
        if let note = self.basicInfo?["note"] as? String {
            TDSwiftAlert.showSingleButtonAlert(title: "Special Instruction", message: note, actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        }
    }
    
    @IBAction func actionBtnClicked(_ sender: HMBasicButton) {
        if let currentTripDetailType = currentTripDetailType,
            let actionTitle = actionInfo?[currentTripDetailType]?.title,
            let actionDescription = actionInfo?[currentTripDetailType]?.description,
            let action = actions?[currentTripDetailType] {
            TDSwiftAlert.showSingleButtonAlertWithCancel(title: actionTitle, message: actionDescription, actionBtnTitle: "Confirm", cancelBtnTitle: "Cancel", presentVC: self) { action() }
        } else {
            TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "Action missing", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        }
    }
    
    // Data
    var tripToken: String?
    var customerToken: String?
    var currentTripDetailType: HMTripDetailType?
    var routeInfo: TDSwiftRouteDetailMapViewResult?
    var driverInfo: [String:Any]?
    var customerInfo: [String:Any]?
    var basicInfo: [String:Any]?
    var fromAddressInfo: [String:Any]?
    var toAddressInfo: [String:Any]?
    var flightInfo: [String:Any]?
    
    // Action
    var actions: [HMTripDetailType: () -> Void]?
    var actionInfo: [HMTripDetailType: HMActionInfo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDelegate()
        setupActions()
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
    
    private func setupActions() {
        // Init actions
        actions = [:]
        actionInfo = [:]
        
        // Dispatched
        actionInfo![HMTripDetailType.dispatched] = HMActionInfo(title: "Go To Pickup Location",
                                                                description: "You will\nstart sharing location\n&\nnavigate to pickup location\n&\ntext customer ETA notice")
        actions![HMTripDetailType.dispatched] = {
            // Start spinner
            self.spinner.show()
            
            // Dispatch group
            let dispatchGroup = DispatchGroup()
            
            // Trip token, customer token
            guard let tripToken = self.tripToken, let customerToken = self.customerToken else {
                TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "Trip info incomplete", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                return
            }
            
            // Start location sharing
            HMHeartBeat.shared.start()
            
            // Start time, eta time string
            let startTime = TDSwiftDate.getCurrentUTCTimeString(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            var etaTime: String? = nil
            if let routeInfo = self.routeInfo {
                var currentDate = TDSwiftDate.getCurrentDate()
                currentDate.addTimeInterval(routeInfo.expectedTravelTime)
                etaTime = TDSwiftDate.formatDateToDateString(forDate: currentDate, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", withTimeZone: TimeZone(identifier: "UTC")!)
            }
            
            // Modify trip
            dispatchGroup.enter()
            var body: [String:Any] = [:]
            body["status"] = 4
            body["start_time"] = startTime
            if let etaTime = etaTime { body["eta_time"] = etaTime }
            HMTrip.modifyTripDetail(withTripToken: tripToken, body: body, completion: { (result, error) in
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                dispatchGroup.leave()
            })
            
            // SMS Message
            var localizedEtaTime = "N/A"
            if let etaTime = etaTime {
                localizedEtaTime = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: etaTime, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MMM d, h:mm a") ?? "N/A"
            }
            let plateNum = self.driverInfo?["license_num"] as? String ?? "N/A"
            let smsTitle = "\(TDSwiftHavana.shared.auth?.company_name ?? "N/A") ETA Notice"
            let smsMessage = "Your driver is on the way. ETA: \(localizedEtaTime),\nVehicle Plate#: \(plateNum).\nThank you!"
            
            // Send customer SMS
            dispatchGroup.enter()
            HMSms.sendSMS(withCustomerToken: customerToken, body: ["title": smsTitle, "message": smsMessage], completion: { (result, error) in
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Send SMS Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                dispatchGroup.leave()
            })
            
            // Tasks all returned
            dispatchGroup.notify(queue: .main) {
                // Stop spinner
                self.spinner.hide()
                
                // Present address options
                if let fromAddressInfo = self.fromAddressInfo, let pickupAddressString = fromAddressInfo["addr_str"] as? String {
                    TDSwiftMapTools.showAddressOptions(onViewController: self, withAddress: pickupAddressString, completion: nil)
                }
                
                // Reload trip detail
                self.loadData()
            }
        }
        
        // On the way
        actionInfo![HMTripDetailType.onTheWay] = HMActionInfo(title: "Send Arrival",
                                                              description: "You will\nconfirm arrival for pickup\n&\ntext customer arrival notice")
        actions![HMTripDetailType.onTheWay] = {
            // Start spinner
            self.spinner.show()
            
            // Dispatch group
            let dispatchGroup = DispatchGroup()
            
            // Trip token, customer token
            guard let tripToken = self.tripToken, let customerToken = self.customerToken else {
                TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "Trip info incomplete", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                return
            }
            
            // Arrive time
            let arriveTime = TDSwiftDate.getCurrentUTCTimeString(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            
            // Modify trip
            dispatchGroup.enter()
            var body: [String:Any] = [:]
            body["status"] = 5
            body["arrive_time"] = arriveTime
            HMTrip.modifyTripDetail(withTripToken: tripToken, body: body, completion: { (result, error) in
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                dispatchGroup.leave()
            })
            
            // SMS Message
            let fromAddressString = self.fromAddressInfo?["addr_str"] as? String ?? "N/A"
            let smsTitle = "\(TDSwiftHavana.shared.auth?.company_name ?? "N/A") Arrival Notice"
            let smsMessage = "Your driver just arrived pickup location: \(fromAddressString). Please get ready for your trip.\nThank you!"
            
            // Send customer SMS
            dispatchGroup.enter()
            HMSms.sendSMS(withCustomerToken: customerToken, body: ["title": smsTitle, "message": smsMessage], completion: { (result, error) in
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Send SMS Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                dispatchGroup.leave()
            })
            
            // Tasks all returned
            dispatchGroup.notify(queue: .main) {
                // Stop spinner
                self.spinner.hide()
                
                // Reload trip detail
                self.loadData()
            }
        }
        
        // Arrived
        actionInfo![HMTripDetailType.arrived] = HMActionInfo(title: "Send Customer On Board",
                                                             description: "You will\nconfirm customer on board\n&\nnavigate to customer dropoff location\n&\ntext customer COB notice")
        actions![HMTripDetailType.arrived] = {
            // Start spinner
            self.spinner.show()
            
            // Dispatch group
            let dispatchGroup = DispatchGroup()
            
            // Trip token, customer token
            guard let tripToken = self.tripToken, let customerToken = self.customerToken else {
                TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "Trip info incomplete", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                return
            }
            
            // COB time
            let cobTime = TDSwiftDate.getCurrentUTCTimeString(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            
            // Modify trip
            dispatchGroup.enter()
            var body: [String:Any] = [:]
            body["status"] = 6
            body["cob_time"] = cobTime
            HMTrip.modifyTripDetail(withTripToken: tripToken, body: body, completion: { (result, error) in
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                dispatchGroup.leave()
            })
            
            // SMS Message
            let toAddressString = self.toAddressInfo?["addr_str"] as? String ?? "N/A"
            var durationString = "N/A"
            if let routeInfo = self.routeInfo {
                let intervalInMin = TDSwiftUnitConverter.secondToMinute(intervalInSecond: Int(routeInfo.expectedTravelTime))
                durationString = "\(String(format: "%.0f", intervalInMin)) min"
            }
            let smsTitle = "\(TDSwiftHavana.shared.auth?.company_name ?? "N/A") COB Notice"
            let smsMessage = "Welcome on board! The destination of your trip is: \(toAddressString). It would take about \(durationString) to get your destination.\nEnjoy your trip.\nThank you!"
            
            // Send customer SMS
            dispatchGroup.enter()
            HMSms.sendSMS(withCustomerToken: customerToken, body: ["title": smsTitle, "message": smsMessage], completion: { (result, error) in
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Send SMS Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                dispatchGroup.leave()
            })
            
            // Tasks all returned
            dispatchGroup.notify(queue: .main) {
                // Stop spinner
                self.spinner.hide()
                
                // Present address options
                if let toAddressInfo = self.toAddressInfo, let dropoffAddressString = toAddressInfo["addr_str"] as? String {
                    TDSwiftMapTools.showAddressOptions(onViewController: self, withAddress: dropoffAddressString, completion: nil)
                }
                
                // Reload trip detail
                self.loadData()
            }
        }
        
        // COB
        actionInfo![HMTripDetailType.cob] = HMActionInfo(title: "Send Customer Arrive Destination",
                                                         description: "You will\nconfirm customer arrived at destination\n&\nstop sharing location\n&\ntext customer CAD notice")
        actions![HMTripDetailType.cob] = {
            // Start spinner
            self.spinner.show()
            
            // Dispatch group
            let dispatchGroup = DispatchGroup()
            
            // Trip token, customer token
            guard let tripToken = self.tripToken, let customerToken = self.customerToken else {
                TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "Trip info incomplete", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                return
            }
            
            // Stop location sharing
            HMHeartBeat.shared.stop()
            
            // CAD time
            let cadTime = TDSwiftDate.getCurrentUTCTimeString(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            
            // Modify trip
            dispatchGroup.enter()
            var body: [String:Any] = [:]
            body["status"] = 7
            body["cad_time"] = cadTime
            HMTrip.modifyTripDetail(withTripToken: tripToken, body: body, completion: { (result, error) in
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                dispatchGroup.leave()
            })
            
            // SMS Message
            let smsTitle = "\(TDSwiftHavana.shared.auth?.company_name ?? "N/A") CAD Notice"
            let smsMessage = "Thank your so much for using our service. See you next time."
            
            // Send customer SMS
            dispatchGroup.enter()
            HMSms.sendSMS(withCustomerToken: customerToken, body: ["title": smsTitle, "message": smsMessage], completion: { (result, error) in
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Send SMS Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                dispatchGroup.leave()
            })
            
            // Tasks all returned
            dispatchGroup.notify(queue: .main) {
                // Stop spinner
                self.spinner.hide()
                
                // Reload trip detail
                self.loadData()
            }
        }
        
        // CAD
        if let amount = self.basicInfo?["amount"] as? Int {
            let amountString = TDSwiftUnitConverter.centToDollar(amountInCent: amount)
            actionInfo![HMTripDetailType.cad] = HMActionInfo(title: "Collect Cash Payment",
                                                             description: "Confirm cash payment of $\(amountString)")
            actions![HMTripDetailType.cad] = {
                // Start spinner
                self.spinner.show()
                
                // Dispatch group
                let dispatchGroup = DispatchGroup()
                
                // Trip token, customer token
                guard let tripToken = self.tripToken else {
                    TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "Trip info incomplete", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                    return
                }
                
                // Modify trip
                dispatchGroup.enter()
                var body: [String:Any] = [:]
                body["is_paid"] = true
                HMTrip.modifyTripDetail(withTripToken: tripToken, body: body, completion: { (result, error) in
                    if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                    dispatchGroup.leave()
                })
                
                // Tasks all returned
                dispatchGroup.notify(queue: .main) {
                    // Stop spinner
                    self.spinner.hide()
                    
                    // Reload trip detail
                    self.loadData()
                }
            }
        } else {
            actionInfo![HMTripDetailType.cad] = HMActionInfo(title: "Unable to process payment",
                                                             description: "Trip total not provided")
            actions![HMTripDetailType.cad] = {}
        }
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
        // Data
        self.customerToken = (data["customer_info"] as? [String : Any])?["customer_token"] as? String
        self.driverInfo = data["driver_info"] as? [String : Any]
        self.customerInfo = data["customer_info"] as? [String : Any]
        self.basicInfo = data["basic_info"] as? [String : Any]
        self.fromAddressInfo = data["from_address_info"] as? [String : Any]
        self.toAddressInfo = data["to_address_info"] as? [String : Any]
        self.flightInfo = data["flight_info"] as? [String : Any]
        
        // Flight info button
        if self.flightInfo != nil && self.flightInfo!.count > 0 {
            // Enable flight info btn
            self.flightInfoBtn.isEnabled = true
            
            // Set flight info btn title
            if let carrierCode = self.flightInfo?["carrier_code"] as? String, let flightNum = self.flightInfo?["flight_num"] as? String {
                self.flightInfoBtn.setTitle("\(carrierCode) \(flightNum)", for: .normal)
            } else {
                self.flightInfoBtn.setTitle(CONST.UI.NOT_AVAILABLE_PLACEHOLDER, for: .normal)
            }
        } else {
            // Disable flight info btn
            self.flightInfoBtn.isEnabled = false
            self.flightInfoBtn.setTitle(CONST.UI.NOT_AVAILABLE_PLACEHOLDER, for: .disabled)
        }
        
        // Trip detail type
        if let status = self.basicInfo?["status"] as? Int {
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
        if let pickupTimeString = self.basicInfo?["pickup_time"] as? String {
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
                // Request current location
                currentLocationManager.delegate = self
                currentLocationManager.requestLocation()
            case .arrived:
                // ConfigM mapview
                mapView.showsUserLocation = false
                mapView.config(config: TDSwiftRouteDetailMapView.defaultConfig,
                               info: TDSwiftRouteDetailMapViewInfo(sourceTitle: "Pickup \(pickupTimeString)",
                                destinationTitle: "Dropoff",
                                sourceLocation: CLLocation(latitude: pickupLat, longitude: pickupLng),
                                destinationLocation: CLLocation(latitude: dropoffLat, longitude: dropoffLng)))
                mapView.drawRoute(removeOldRoute: true) { (info, error) in
                    if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "Render map with error: \(error)", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                    if let info = info {
                        self.routeInfo = info
                        self.displayRouteInfo(withInfo: info)
                    }
                }
            case .cob:
                // Config mapview
                mapView.showsUserLocation = false
                mapView.config(config: TDSwiftRouteDetailMapView.defaultConfig,
                               info: TDSwiftRouteDetailMapViewInfo(sourceTitle: "Customer On Board",
                                                                   destinationTitle: "Dropoff",
                                                                   sourceLocation: CLLocation(latitude: pickupLat, longitude: pickupLng),
                                                                   destinationLocation: CLLocation(latitude: dropoffLat, longitude: dropoffLng)))
                mapView.drawRoute(removeOldRoute: true) { (info, error) in
                    if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "Render map with error: \(error)", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                    if let info = info {
                        self.routeInfo = info
                        self.displayRouteInfo(withInfo: info)
                    }
                }
            case .cad:
                // Cad time
                if let utcCadTimeString = self.basicInfo?["cad_time"] as? String,
                    let cadTimeString = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: utcCadTimeString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "h:mm a"){
                    // ConfigM mapview
                    mapView.showsUserLocation = false
                    mapView.config(config: TDSwiftRouteDetailMapView.defaultConfig,
                                   info: TDSwiftRouteDetailMapViewInfo(sourceTitle: "Pickup \(pickupTimeString)",
                                    destinationTitle: "Dropoff \(cadTimeString)",
                                    sourceLocation: CLLocation(latitude: pickupLat, longitude: pickupLng),
                                    destinationLocation: CLLocation(latitude: dropoffLat, longitude: dropoffLng)))
                    mapView.drawRoute(removeOldRoute: true) { (info, error) in
                        if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "Render map with error: \(error)", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                        if let info = info {
                            self.routeInfo = info
                            self.displayRouteInfo(withInfo: info)
                        }
                    }                } else {
                    TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "CAD time not found", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                }
            }
        } else {
            TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "Location info unavailable", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        }
        
        // Action button title
        switch currentTripDetailType {
        case .dispatched:
            actionBtn.changeButtonState(to: .enabled)
            actionBtn.setTitle("Go To Pickup Location", for: .normal)
        case .onTheWay:
            actionBtn.changeButtonState(to: .enabled)
            actionBtn.setTitle("Send Arrival", for: .normal)
        case .arrived:
            actionBtn.changeButtonState(to: .enabled)
            actionBtn.setTitle("Customer On Board", for: .normal)
        case .cob:
            actionBtn.changeButtonState(to: .enabled)
            actionBtn.setTitle("Customer Arrival Destination", for: .normal)
        case .cad:
            setActionBtnPaymentState()
        }
        
        // From, to address
        if let fromAddressString = (data["from_address_info"] as? [String : Any])?["addr_str"] as? String {
            routeDetailView.upperAddressBtn.setTitle(fromAddressString, for: .normal)
        }
        if let toAddressString = (data["to_address_info"] as? [String : Any])?["addr_str"] as? String {
            routeDetailView.lowerAddressBtn.setTitle(toAddressString, for: .normal)
        }
        
        // Special instruction
        if (data["basic_info"] as? [String : Any])?["note"] as? String != nil {
            specialInstructionBtn.isEnabled = true
        } else {
            specialInstructionBtn.isEnabled = false
        }
        
        // Hide spinner
        if currentTripDetailType != .dispatched && currentTripDetailType != .onTheWay {
            self.spinner.hide()
        }
    }
    
    private func setActionBtnPaymentState() {
        // Payment type
        guard let paymentType = self.basicInfo?["type"] as? Int else {
            actionBtn.changeButtonState(to: .disabled)
            actionBtn.setTitle(CONST.UI.NOT_AVAILABLE_PLACEHOLDER, for: .normal)
            return
        }
        
        // Button state for different payment types
        switch paymentType {
        case 3:
            actionBtn.changeButtonState(to: .enabled)
            actionBtn.setTitle("Pay With Cash", for: .normal)
        default:
            actionBtn.changeButtonState(to: .disabled)
            actionBtn.setTitle("Payment Method Not Supported", for: .normal)
        }
    }
    
    private func displayRouteInfo(withInfo info: TDSwiftRouteDetailMapViewResult) {
        let distanceInMile = TDSwiftUnitConverter.meterToMile(distanceInMeter: info.distance)
        let intervalInMin = TDSwiftUnitConverter.secondToMinute(intervalInSecond: Int(info.expectedTravelTime))
        
        routeInfoLabel.text = "\(String(format: "%.1f", distanceInMile))mi/\(String(format: "%.0f", intervalInMin))min"
    }
    
    func alertParseDataFailed() {
        TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Server response invalid", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: HMCustomerMessagingViewController.self) {
            let messagingVC = segue.destination as! HMCustomerMessagingViewController
            messagingVC.customerToken = self.customerInfo?["customer_token"] as? String
        }
    }
}

extension HMTripDetailViewController: TDSwiftPopoverDelegate {
    func didSelect(item: TDSwiftPopoverItem, atIndex index: Int) {
        switch index {
        case 0: // Text customer
            performSegue(withIdentifier: String(describing: HMCustomerMessagingViewController.self), sender: self)
        case 1: // Call customer
            if let customerCell = self.customerInfo?["cell"] as? String, let callURL = URL(string: "telprompt://\(customerCell)"), UIApplication.shared.canOpenURL(callURL) {
                UIApplication.shared.open(callURL, options: [:], completionHandler: nil)
            } else {
                TDSwiftAlert.showSingleButtonAlert(title: "Failed", message: "Customer contact info not provided", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
            }
        case 2: // Call Dispatch Center
            if (HMGlobal.shared.isDispatchCellAvailable()) {
                HMGlobal.shared.callDispatchCenter()
            } else {
                TDSwiftAlert.showSingleButtonAlert(title: "Failed", message: "Dispatch center info missing", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
            }
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

extension HMTripDetailViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // If is rendering dispatched or on the way map
        if let currentTripDetailType = self.currentTripDetailType, (currentTripDetailType == .dispatched || currentTripDetailType == .onTheWay) {
            // Hide spinner
            self.spinner.hide()
            
            // Pickup location
            guard let pickupLat = self.fromAddressInfo?["lat"] as? Double,
                let pickupLng = self.fromAddressInfo?["lng"] as? Double,
                let utcPickupTimeString = self.basicInfo?["pickup_time"] as? String,
                let pickupTimeString = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: utcPickupTimeString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "h:mm a") else {
                    TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "Pickup location unavailable", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                    return
            }
            
            // Current location
            let currentCoordinate = locations.last?.coordinate
            if currentCoordinate == nil {
                TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "Your location is temporarily unavailable", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                return
            }
            let currentLocation = CLLocation(latitude: currentCoordinate!.latitude, longitude: currentCoordinate!.longitude)
            
            // Config mapview
            mapView.showsUserLocation = true
            mapView.config(config: TDSwiftRouteDetailMapView.defaultConfig,
                           info: TDSwiftRouteDetailMapViewInfo(sourceTitle: "Driver Location",
                                                               destinationTitle: "Pickup \(pickupTimeString)",
                            sourceLocation: currentLocation,
                            destinationLocation: CLLocation(latitude: pickupLat, longitude: pickupLng)))
            mapView.drawRoute(removeOldRoute: true) { (info, error) in
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "Render map with error: \(error)", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                if let info = info {
                    self.routeInfo = info
                    self.displayRouteInfo(withInfo: info)
                }
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // If is rendering dispatched or on the way map
        if let currentTripDetailType = self.currentTripDetailType, (currentTripDetailType == .dispatched || currentTripDetailType == .onTheWay) {
            // Hide spinner
            self.spinner.hide()
            
            // Failed to get current location
            TDSwiftAlert.showSingleButtonAlert(title: "Map Error", message: "Your location is temporarily unavailable", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        }
    }
}
