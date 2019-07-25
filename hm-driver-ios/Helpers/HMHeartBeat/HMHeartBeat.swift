import Foundation
import MapKit

public class HMHeartBeat {
    // Config heart beat
    private init() {
        TDSwiftHeartBeat.shared.config(config: TDSwiftHeartBeatConfig(timeInterval: 5.0, action: {
            // Latest location
            guard let latestCoordinate = HMLocationManager.shared.loadLocation() else {
                print("Location temporarily unavailable")
                return
            }
            
            // Register location
            HMDriver.registerLocation(body: ["lat": latestCoordinate.latitude, "lng": latestCoordinate.longitude], completion: { (result, error) in
                if error != nil { print("Register location error: \(String(describing: error))") }
            })
        }))
    }
    
    // Singleton instance
    public static let shared = HMHeartBeat()
    
    public func start() {
        _ = TDSwiftHeartBeat.shared.start()
        
        // Update ui if needed
        updateUI()
    }
    
    public func stop() {
        TDSwiftHeartBeat.shared.stop()
    }
    
    public func getSharingButtonTitle() -> String {
        switch TDSwiftHeartBeat.shared.getHeartBeatStatus() {
        case .activated:
            return "Sharing Location(Activated)"
        case .terminated:
            return "Sharing Location"
        }
    }
    
    private func updateUI() {
        // Update account vc start sharing button
        if let accountVC = HMViewControllerManager.shared.presentingViewController as? HMAccountViewController {
            accountVC.updateSharingLocationLabel()
        }
    }
}
