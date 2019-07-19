import Foundation
import UIKit

class HMFlightInfoViewController: TDSwiftAnimateBackgroundViewController {
    var flightInfo: [String:Any]?
    let flightInfoTitles = [
            "Departure date",
            "Arrival date",
            "Departure airport",
            "Departure terminal",
            "Arrival airport",
            "Arrival terminal",
            "Carrier code",
            "Flight number"
    ]
    
    var flightInfoDetails: [String:String] = [:]
    
    @IBOutlet weak var bgView: TDSwiftRoundedCornerView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func dismissBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        parseFlightInfo()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupAppearance() {
        // Background view
        bgView.roundedCorners = [.topLeft, .topRight]
    }
    
    private func parseFlightInfo() {
        // Departure date
        if let depDateString = self.flightInfo?["dep_date"] as? String,
            let depDateLocalString = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: depDateString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MMM d' - 'h:mm a") {
            flightInfoDetails[flightInfoTitles[0]] = depDateLocalString
        }
        
        // Arrival date
        if let arrDateString = self.flightInfo?["arr_date"] as? String,
            let arrDateLocalString = TDSwiftDate.utcTimeStringToLocalTimeString(timeString: arrDateString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MMM d' - 'h:mm a") {
            flightInfoDetails[flightInfoTitles[1]] = arrDateLocalString
        }
        
        // Departure airport
        if let depAirport = self.flightInfo?["dep_airport"] as? String {
            flightInfoDetails[flightInfoTitles[2]] = depAirport
        }
        
        // Departure terminal
        if let depTerminal = self.flightInfo?["dep_terminal"] as? String {
            flightInfoDetails[flightInfoTitles[3]] = depTerminal
        }
        
        // Arrival airport
        if let arrAirport = self.flightInfo?["arr_airport"] as? String {
            flightInfoDetails[flightInfoTitles[4]] = arrAirport
        }
        
        // Arrival terminal
        if let arrTerminal = self.flightInfo?["arr_terminal"] as? String {
            flightInfoDetails[flightInfoTitles[5]] = arrTerminal
        }
        
        // Carrier code
        if let carrierCode = self.flightInfo?["carrier_code"] as? String {
            flightInfoDetails[flightInfoTitles[6]]  = carrierCode
        }
        
        // Flight number
        if let flightNum = self.flightInfo?["flight_num"] as? String {
            flightInfoDetails[flightInfoTitles[7]] = flightNum
        }
        
        // Reload tableView
        tableView.reloadData()
    }
}

extension HMFlightInfoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flightInfoTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cell instance
        let cell = tableView.dequeueReusableCell(withIdentifier: "HMFlightDetailLeftDetailCell")!
        
        // Title
        cell.textLabel?.text = flightInfoTitles[indexPath.row]
        
        // Detail
        cell.detailTextLabel?.text = flightInfoDetails[flightInfoTitles[indexPath.row]] ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER
        
        // Result
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
