import Foundation

class HMGlobal {
    // Hide init
    private init() {}
    
    // Singleton instance
    let shared = HMGlobal()
    
    // Data
    var dispatchCell: String?
    
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
}
