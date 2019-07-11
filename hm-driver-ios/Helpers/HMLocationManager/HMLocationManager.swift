import Foundation
import CoreLocation

public class HMLocationManager {
    // Singleton instance
    public static let shared = HMLocationManager()
    
    // Location Manager instance
    public var locationManager: CLLocationManager
    
    // Config location manager
    private init() {
        // Init location manager
        locationManager = CLLocationManager()
    }
    
    // Current servise permission status
    public func getServiceAuthorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    // Request for always authorization
    public func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
}
