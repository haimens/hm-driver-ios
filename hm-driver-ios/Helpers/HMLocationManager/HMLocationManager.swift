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
    
    // Cache last location
    public func cacheLocation(coordinate: CLLocationCoordinate2D) {
        UserDefaults.standard.set([coordinate.latitude, coordinate.longitude], forKey: CONST.LOCATION.LAST_LOCATION_CACHE_KEY)
    }
    
    // Load lst location
    public func loadLocation() -> CLLocationCoordinate2D? {
        if let cachedLocation = UserDefaults.standard.value(forKey: CONST.LOCATION.LAST_LOCATION_CACHE_KEY) as? [CLLocationDegrees] {
            return CLLocationCoordinate2D(latitude: cachedLocation[0], longitude: cachedLocation[1])
        } else {
            return nil
        }
    }
}
