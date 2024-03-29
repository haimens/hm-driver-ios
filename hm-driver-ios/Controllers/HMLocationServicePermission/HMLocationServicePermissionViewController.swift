import UIKit
import CoreLocation

struct HMLocationServicePermissionState {
    let description: String
    let actionTitle: String
    let preAction: () -> Void
    let action: () -> Void
}

class HMLocationServicePermissionViewController: UIViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var actionBtn: HMBasicButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    @IBAction func actionBtnClicked(_ sender: HMBasicButton) { currentAction?() }
    
    @IBAction func skipBtnClicked(_ sender: UIButton) {
        if let authVC = self.presentingViewController as? HMAuthViewController {
            authVC.shouldVerifyPermission = false
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var states: [CLAuthorizationStatus: HMLocationServicePermissionState]!
    var currentAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        configStates()
        updateUIBaseOnAuthorizationStatus()
    }
    
    private func setupDelegate() {
        HMLocationManager.shared.locationManager.delegate = self
    }
    
    private func configStates() {
        // Init states
        states = [:]
        
        // Not determined
        let notDeterminedDescription = "We need following permission(s) to be able to have this App working properly:\n\nLocation Service Permission - Always Allow\n\nPlease grant us your permission in the following popup window."
        states[CLAuthorizationStatus.notDetermined] = HMLocationServicePermissionState(description: notDeterminedDescription,
                                                                                       actionTitle: "Grant Permission",
                                                                                       preAction: { self.skipBtn.isHidden = true },
                                                                                       action: {
                                                                                        HMLocationManager.shared.requestAlwaysAuthorization()
        })
        
        // Restricted
        let restrictedDescription = "The location services on this device is restricted, please enable the location services (such as swicth off Airplane Mode) then check again."
        states[CLAuthorizationStatus.restricted] = HMLocationServicePermissionState(description: restrictedDescription,
                                                                                       actionTitle: "Verify Service Status",
                                                                                       preAction: { self.skipBtn.isHidden = false },
                                                                                       action: {
                                                                                        self.updateUIBaseOnAuthorizationStatus()
        })
        
        // Denied, inUse
        let deniedOrInUseDescription = "The location services on this device is denied or only authorized when in use. Please authorize the App to use the location services all the time in settings then verify service status again."
        let deniedOrInUseState = HMLocationServicePermissionState(description: deniedOrInUseDescription,
                                                                  actionTitle: "Verify Service Status",
                                                                  preAction: { self.skipBtn.isHidden = false },
                                                                  action: {
                                                                    self.updateUIBaseOnAuthorizationStatus()
        })
        states[CLAuthorizationStatus.denied] = deniedOrInUseState
        states[CLAuthorizationStatus.authorizedWhenInUse] = deniedOrInUseState
    }
    
    private func updateUIBaseOnAuthorizationStatus() {
        // Current status
        let status = HMLocationManager.shared.getServiceAuthorizationStatus()
        
        switch status {
        case .notDetermined:
            updateUI(withState: states[status]!)
        case .restricted, .denied:
            updateUI(withState: states[status]!)
        case .authorizedWhenInUse:
            updateUI(withState: states[status]!)
        case .authorizedAlways:
            // Dismiss location vc
            self.dismiss(animated: true, completion: nil)
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateUI(withState state: HMLocationServicePermissionState) {
        // Pre action
        state.preAction()
        
        // Update UI elements state
        descriptionTextView.text = state.description
        actionBtn.setTitle(state.actionTitle, for: .normal)
        self.currentAction = state.action
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add presenting vc reference
        HMViewControllerManager.shared.presentingViewController = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove presenting vc reference
        HMViewControllerManager.shared.unlinkPresentingViewController(withViewController: self)
    }
}

extension HMLocationServicePermissionViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateUIBaseOnAuthorizationStatus()
    }
}
