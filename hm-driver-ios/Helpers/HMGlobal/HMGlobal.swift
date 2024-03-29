import Foundation
import UIKit

class HMGlobal {
    // Hide init
    private init() {}
    
    // Singleton instance
    static let shared = HMGlobal()
    
    // Data
    private var dispatchCell: String? {
        get {
            return UserDefaults.standard.value(forKey: CONST.GLOBAL.GLOBAL_INFO_CONTACT_CELL_KEY) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: CONST.GLOBAL.GLOBAL_INFO_CONTACT_CELL_KEY)
        }
    }
    
    // Request for global data
    func makeGlobalRequest() {
        // Dispatch cell
        HMSetting.getSettingDetail(withKey: "contact_cell") { (result, error) in
            DispatchQueue.main.async {
                // Parse dispatch cell
                if var dispatch_cell = result?["value"] as? String {
                    dispatch_cell = dispatch_cell.trimmingCharacters(in: .whitespacesAndNewlines)
                    dispatch_cell = dispatch_cell.replacingOccurrences(of: " ", with: "")
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
