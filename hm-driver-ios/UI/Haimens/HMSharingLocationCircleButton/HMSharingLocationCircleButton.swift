import Foundation
import UIKit

class HMSharingLocationCircleButton: TDSwiftIconCircleButton {
    public var presentingViewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Appearance
        updateButtonStatus()
        
        // Action
        self.addTarget(self, action: #selector(self.btnClicked(_:)), for: .touchUpInside)
    }
    
    public func updateButtonStatus() {
        switch TDSwiftHeartBeat.shared.getHeartBeatStatus() {
        case .activated:
            renderStopAppearance()
        case .terminated:
            renderStartAppearance()
        }
    }
    
    private func renderStartAppearance() {
        self.backgroundColor = .white
        self.iconImage = #imageLiteral(resourceName: "navigation-icon")
        self.updateAppearance()
    }
    
    private func renderStopAppearance() {
        self.backgroundColor = UIColor(red:0.97, green:0.34, blue:0.46, alpha:1.0)
        self.iconImage = #imageLiteral(resourceName: "stop-icon-1")
        self.updateAppearance()
    }
    
    @objc private func btnClicked(_ sender:UIButton) {
        if HMLocationManager.shared.getServiceAuthorizationStatus() == .authorizedAlways {
            switch TDSwiftHeartBeat.shared.getHeartBeatStatus() {
            case .activated:
                HMHeartBeat.shared.stop()
                if let presentingViewController = presentingViewController {
                    TDSwiftAlert.showSingleButtonAlert(title: "Location Sharing", message: "Service Terminated", actionBtnTitle: "OK", presentVC: presentingViewController, btnAction: nil)
                }
                updateButtonStatus()
            case .terminated:
                HMHeartBeat.shared.start()
                if let presentingViewController = presentingViewController {
                    TDSwiftAlert.showSingleButtonAlert(title: "Location Sharing", message: "Service Started", actionBtnTitle: "OK", presentVC: presentingViewController, btnAction: nil)
                }
                updateButtonStatus()
            }
        } else {
            if let presentingViewController = presentingViewController {
                TDSwiftAlert.showSingleButtonAlert(title: "Action Failed", message: "Location service not authorized", actionBtnTitle: "OK", presentVC: presentingViewController, btnAction: nil)
            }
        }
    }
}
