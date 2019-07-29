import UIKit
import MapKit

struct HMActionInfo {
    let title: String
    let description: NSAttributedString
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
    var popover: HMTripDetailPopover!
    var spinner: TDSwiftSpinner!
    
    let currentLocationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: TDSwiftRouteDetailMapView!
    @IBOutlet weak var routeDetailView: HMRouteDetailView!
    @IBOutlet weak var specialInstructionBtn: TDSwiftRoundedIconGradientButton!
    @IBOutlet weak var routeInfoLabel: UILabel!
    @IBOutlet weak var actionBtn: HMBasicButton!
    @IBOutlet weak var flightInfoBtn: TDSwiftRoundedIconGradientButton!
    @IBOutlet weak var locationSharingBtn: HMSharingLocationCircleButton!
    @IBOutlet weak var infoBtnStackView: UIStackView!
    @IBOutlet weak var tripDetailBGView: HMTripDetailBGView!
    
    @IBAction func flightInfoBtnClicked(_ sender: TDSwiftRoundedIconGradientButton) {
        performSegue(withIdentifier: String(describing: HMFlightInfoViewController.self), sender: self)
    }
    
    @IBAction func specialInstructionBtnClicked(_ sender: TDSwiftRoundedIconGradientButton) {
        // Show note if available
        if let note = self.basicInfo?["note"] as? String {
            TDSwiftAlert.showSingleButtonAlert(title: "Special Instruction", message: note, actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        }
    }
    
    @IBAction func messagingBtnClicked(_ sender: TDSwiftIconCircleButton) {
        performSegue(withIdentifier: String(describing: HMCustomerMessagingNavigationController.self), sender: self)
    }
    
    @IBAction func actionBtnClicked(_ sender: HMBasicButton) {
        // If action type is on the way or cob, config actions first
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.spinner.show()
        if let currentTripDetailType = currentTripDetailType,
            currentTripDetailType == .onTheWay || currentTripDetailType == .cob {
            // Request for current location
            TDSwiftLocationManager.shared.requestCurrentLocation { (location, error) in
                if error != nil { TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Current location not available", actionBtnTitle: "OK", presentVC: self, btnAction: nil); return }
                if let location = location {
                    // Setup action
                    if currentTripDetailType == .onTheWay {
                        self.setupOnTheWayAction(withCurrentLocation: location)
                    } else if currentTripDetailType == .cob {
                        self.setupCOBAction(withCurrentLocation: location)
                    }
                }
                dispatchGroup.leave()
            }
        } else if let currentTripDetailType = currentTripDetailType,
            currentTripDetailType == .cad {
            setupCADAction()
            dispatchGroup.leave()
        } else {
            dispatchGroup.leave()
        }
        
        // Run action
        dispatchGroup.notify(queue: .main) {
            self.spinner.hide()
            if let currentTripDetailType = self.currentTripDetailType,
                let actionTitle = self.actionInfo?[currentTripDetailType]?.title,
                let actionDescription = self.actionInfo?[currentTripDetailType]?.description,
                let action = self.actions?[currentTripDetailType] {
                TDSwiftAlert.showSingleButtonAlertWithCancelWithAttributedMessage(title: actionTitle, message: actionDescription, actionBtnTitle: "Confirm", cancelBtnTitle: "Cancel", presentVC: self, btnAction: { action() })
            } else {
                TDSwiftAlert.showSingleButtonAlert(title: "Update Trip Failed", message: "Action missing", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        // Add presenting vc reference
        HMViewControllerManager.shared.presentingViewController = self
        
        configNavigationAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        popover.dismiss()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove presenting vc reference
        HMViewControllerManager.shared.unlinkPresentingViewController(withViewController: self)
    }
    
    private func setupUI() {
        // Navigation appearance
        configNavigationAppearance()
        
        // Menu bar button
        navigationItem.rightBarButtonItem = HMThreeDotsBarButtonItem(target: self, selector: #selector(self.showOptionsMenu(_:)))
        
        // Popover menu
        popover = HMTripDetailPopover()
        
        // Spinner
        spinner = TDSwiftSpinner(viewController: self)
        
        // Location sharing button
        locationSharingBtn.presentingViewController = self
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
                                                                description: NSAttributedString(string: "You will\n○ Start sharing location\n○ Navigate to pickup location\n○ Text customer ETA notice", attributes: CONST.UI.STRING_ATTRIBUTES_LEFT_PARAGRAPH))
        actions![HMTripDetailType.dispatched] = {
            // Start time, eta time string
            let startTime = TDSwiftDate.getCurrentUTCTimeString(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            var etaTime: String? = nil
            if let routeInfo = self.routeInfo {
                var currentDate = TDSwiftDate.getCurrentDate()
                currentDate.addTimeInterval(routeInfo.expectedTravelTime)
                etaTime = TDSwiftDate.formatDateToDateString(forDate: currentDate, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", withTimeZone: TimeZone(identifier: "UTC")!)
            } else {
                TDSwiftAlert.showSingleButtonAlert(title: "Calculating ETA Time", message: "Map rendering, please try again later", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                return
            }
            
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
        
        // Arrived
        actionInfo![HMTripDetailType.arrived] = HMActionInfo(title: "Send Customer On Board",
                                                             description: NSAttributedString(string: "You will\n○ Confirm customer on board\n○ Navigate to customer dropoff location\n○ Text customer COB notice", attributes: CONST.UI.STRING_ATTRIBUTES_LEFT_PARAGRAPH))
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
    }
    
    private func setupOnTheWayAction(withCurrentLocation currentLocation: CLLocation) {
        // Pickup location
        guard let pickupLat = self.fromAddressInfo?["lat"] as? Double,
            let pickupLng = self.fromAddressInfo?["lng"] as? Double else {
                actionInfo![HMTripDetailType.onTheWay] = HMActionInfo(title: "Request Failed", description: NSAttributedString(string: "Pick up location not available", attributes: CONST.UI.STRING_ATTRIBUTES_CENTER_PARAGRAPH))
                actions![HMTripDetailType.onTheWay] = {}
                return
        }
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLng)
        
        // Distance between current and pickup location in meters
        let distance = currentLocation.distance(from: pickupLocation)
        
        // Distance too far
        var distanceTooFar = false
        if distance > 50.0 { distanceTooFar = true }
        
        // Info
        let actionDescription = NSMutableAttributedString(string: "You will\n○ Confirm arrival for pickup\n○ Text customer arrival notice\n", attributes: CONST.UI.STRING_ATTRIBUTES_LEFT_PARAGRAPH)
        actionDescription.append(NSAttributedString(string: "Warning: your current location is too far away from the registered customer pick up location, an alert will be sent to dispatch if continue", attributes: CONST.UI.STRING_ATTRIBUTES_LEFT_PARAGRAPH_ALARM))
        if distanceTooFar {
            actionInfo![HMTripDetailType.onTheWay] = HMActionInfo(title: "Send Arrival",
                                                                  description: actionDescription)
        } else {
            actionInfo![HMTripDetailType.onTheWay] = HMActionInfo(title: "Send Arrival",
                                                                  description: NSAttributedString(string: "You will\n○ Confirm arrival for pickup\n○ Text customer arrival notice", attributes: CONST.UI.STRING_ATTRIBUTES_LEFT_PARAGRAPH))
        }
        
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
            
            // SMS warning
            if distanceTooFar {
                dispatchGroup.enter()
                let driverName = self.driverInfo?["name"] as? String ?? "N/A"
                let driverCell = self.driverInfo?["cell"] as? String ?? "N/A"
                let warningTitle = "Driver Arrival Distance Warning"
                let warningMessage = "Driver \(driverName) is confirming arrival, but driver's current location does not match the customer requested pick up location. Contact driver with number: \(driverCell)"
                HMSms.sendSMSToDispatch(withCustomerToken: customerToken, body: ["title": warningTitle, "message": warningMessage], completion: { (result, error) in
                    if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Send Warning Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                    dispatchGroup.leave()
                })
            }
            
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
    }
    
    private func setupCOBAction(withCurrentLocation currentLocation: CLLocation) {
        // Pickup location
        guard let dropoffLat = self.toAddressInfo?["lat"] as? Double,
            let dropoffLng = self.toAddressInfo?["lng"] as? Double else {
                actionInfo![HMTripDetailType.onTheWay] = HMActionInfo(title: "Request Failed", description: NSAttributedString(string: "Drop off location not available", attributes: CONST.UI.STRING_ATTRIBUTES_CENTER_PARAGRAPH))
                actions![HMTripDetailType.onTheWay] = {}
                return
        }
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLng)
        
        // Distance between current and pickup location in meters
        let distance = currentLocation.distance(from: dropoffLocation)
        
        // Distance too far
        var distanceTooFar = false
        if distance > 50.0 { distanceTooFar = true }
        
        // Info
        let actionDescription = NSMutableAttributedString(string: "You will\n○ Confirm customer arrived at destination\n○ Stop sharing location\n○ Text customer CAD notice\n", attributes: CONST.UI.STRING_ATTRIBUTES_LEFT_PARAGRAPH)
        actionDescription.append(NSAttributedString(string: "Warning: your current location is too far away from the registered customer drop off location, an alert will be sent to dispatch if continue", attributes: CONST.UI.STRING_ATTRIBUTES_LEFT_PARAGRAPH_ALARM))
        if distanceTooFar {
            actionInfo![HMTripDetailType.cob] = HMActionInfo(title: "Send Customer Arrive Destination",
                                                             description: actionDescription)
        } else {
            actionInfo![HMTripDetailType.cob] = HMActionInfo(title: "Send Customer Arrive Destination",
                                                             description: NSAttributedString(string: "You will\n○ Confirm customer arrived at destination\n○ Stop sharing location\n○ Text customer CAD notice", attributes: CONST.UI.STRING_ATTRIBUTES_LEFT_PARAGRAPH))
        }
        
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
            
            // SMS warning
            if distanceTooFar {
                dispatchGroup.enter()
                let driverName = self.driverInfo?["name"] as? String ?? "N/A"
                let driverCell = self.driverInfo?["cell"] as? String ?? "N/A"
                let warningTitle = "Driver Drop Off Distance Warning"
                let warningMessage = "Driver \(driverName) is confirming CAD, but driver's current location does not match the customer requested drop off location. Contact driver with number: \(driverCell)"
                HMSms.sendSMSToDispatch(withCustomerToken: customerToken, body: ["title": warningTitle, "message": warningMessage], completion: { (result, error) in
                    if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Send Warning Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                    dispatchGroup.leave()
                })
            }
            
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
    }
    
    func setupCADAction() {
        // CAD
        if let amount = self.basicInfo?["amount"] as? Int {
            let amountString = TDSwiftUnitConverter.centToDollar(amountInCent: amount)
            actionInfo![HMTripDetailType.cad] = HMActionInfo(title: "Collect Cash Payment",
                                                             description: NSAttributedString(string: "Confirm cash payment of $\(amountString)", attributes: CONST.UI.STRING_ATTRIBUTES_CENTER_PARAGRAPH))
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
                body["is_paid"] = 1
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
                                                             description: NSAttributedString(string: "Trip total not provided", attributes: CONST.UI.STRING_ATTRIBUTES_CENTER_PARAGRAPH))
            actions![HMTripDetailType.cad] = {}
        }
    }
    
    @objc private func showOptionsMenu(_ sender: UIBarButtonItem) {
        // Customer info not available, do not present options menu
        if customerInfo == nil {
            return
        }
        
        // Calculate popover origin
        let buttonItemView = self.navigationItem.rightBarButtonItem!.value(forKey: "view") as! UIView
        let buttonItemViewCenter = buttonItemView.convert(buttonItemView.center, to: self.view)
        let popoverOrigin = CGPoint(x: buttonItemViewCenter.x - 5, y: buttonItemViewCenter.y + 10)
        
        // Present popover
        let popoverInfo = HMTripDetailPopoverInfo(customerImageURLString: self.customerInfo?["img_path"] as? String,
                                                  customerName: self.customerInfo?["name"] as? String,
                                                  customerCell: self.customerInfo?["cell"] as? String)
            popover.present(onView: self.navigationController!.view, atPoint: popoverOrigin, withInfo: popoverInfo)
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
                if let error = error {
                    // Present error message
                    TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: DriverConn.getErrorMessage(error: error), actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                }
                
                // Parse request response
                if let result = result { self.parseData(data: result) }
            }
        }
    }
    
    func parseData(data: [String : Any]) {
        // Location sharing status
        locationSharingBtn.updateButtonStatus()
        
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
            self.flightInfoBtn.enable()
            
            // Set flight info btn title
            if let carrierCode = self.flightInfo?["carrier_code"] as? String, let flightNum = self.flightInfo?["flight_num"] as? String {
                self.flightInfoBtn.text = "\(carrierCode) \(flightNum)"
            } else {
                self.flightInfoBtn.text = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
            }
        } else {
            // Disable flight info btn
            self.flightInfoBtn.disable()
            self.flightInfoBtn.text = CONST.UI.NOT_AVAILABLE_PLACEHOLDER
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
            specialInstructionBtn.enable()
        } else {
            specialInstructionBtn.disable()
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
        case 1: //Prepay
            actionBtn.changeButtonState(to: .disabled)
            actionBtn.setTitle("Prepaid", for: .normal)
        case 3: // Cash
            guard let isPaid = self.basicInfo?["is_paid"] as? Bool else {
                actionBtn.setTitle(CONST.UI.NOT_AVAILABLE_PLACEHOLDER, for: .normal)
                return
            }
            
            // If amount available, show amount button
            if let amount = self.basicInfo?["amount"] as? Int {
                // Formatted amount string
                let amountString = TDSwiftUnitConverter.centToDollar(amountInCent: amount)
                
                // Amount button
                let amountBtn = HMAmountButton(frame: self.infoBtnStackView.frame)
                amountBtn.amountLabel.text = "$ \(amountString)"
                self.tripDetailBGView.addSubview(amountBtn)
            }
            
            if isPaid {
                actionBtn.changeButtonState(to: .disabled)
                actionBtn.setTitle("Cash Paid", for: .normal)
            } else {
                actionBtn.changeButtonState(to: .enabled)
                actionBtn.setTitle("Pay With Cash", for: .normal)
            }
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
        if segue.identifier == String(describing: HMCustomerMessagingNavigationController.self) {
            let messagingNavigationVC = segue.destination as! HMCustomerMessagingNavigationController
            let messagingVC = messagingNavigationVC.viewControllers.first as! HMCustomerMessagingViewController
            messagingVC.customerToken = self.customerInfo?["customer_token"] as? String
        }
        
        if segue.identifier == String(describing: HMFlightInfoViewController.self) {
            let flightInfoVC = segue.destination as! HMFlightInfoViewController
            flightInfoVC.flightInfo = self.flightInfo
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
