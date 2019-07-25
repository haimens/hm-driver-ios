import Foundation
import CoreLocation

public class TDSwiftLocationManager: NSObject {
    public typealias locationResponse = (CLLocation?, Error?)->Void
    
    // Response list
    private var responses: [locationResponse] = []
    
    // Singleton instance
    public static let shared = TDSwiftLocationManager()
    private override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    // Location Manager instance
    public var locationManager: CLLocationManager
    
    // Request for current location
    public func requestCurrentLocation(completion: @escaping locationResponse) {
        // Enqueue response
        responses.append(completion)
        
        // Request for location
        self.locationManager.requestLocation()
    }
}

extension TDSwiftLocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for _ in 0 ..< responses.count {
            let currentResponse = responses.removeFirst()
            currentResponse(locations.last!, nil)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        for _ in 0 ..< responses.count {
            let currentResponse = responses.removeFirst()
            currentResponse(nil, error)
        }
    }
}
