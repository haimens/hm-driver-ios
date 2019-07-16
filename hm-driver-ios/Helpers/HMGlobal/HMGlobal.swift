import Foundation
import UIKit

class HMGlobal {
    // Hide init
    private init() {}
    
    // Singleton instance
    static let shared = HMGlobal()
    
    // Data
    private var dispatchCell: String?
    
    // Request for global data
    func makeGlobalRequest() {
        // Dispatch cell
        HMSetting.getSettingDetail(withKey: "contact_cell") { (result, error) in
            DispatchQueue.main.async {
                // Parse dispatch cell
                if let dispatch_cell = result?["value"] as? String {
                    self.dispatchCell = dispatch_cell
                }
            }
        }
    }
    
    // Is dispatch center phone call available
    func isDispatchCellAvailable() -> Bool {
        return dispatchCell != nil
    }
    
    // Make dispatch center phone call
    func callDispatchCenter() {
        if let dispatchCell = dispatchCell {
            // Phone call URL
            if let callURL = URL(string: "telprompt://\(dispatchCell)"), UIApplication.shared.canOpenURL(callURL) {
                UIApplication.shared.open(callURL, options: [:], completionHandler: nil)
            }
        }
    }
}
