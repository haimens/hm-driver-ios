import Foundation
import CoreLocation

public enum TDSwiftHeartBeatStatus {
    case activated
    case terminated
}

public class TDSwiftHeartBeat: NSObject {
    // Hide initializer
    private override init() {}
    
    // Singleton instance
    public static let shared = TDSwiftHeartBeat()
    
    // Config and timer reference
    private var config: TDSwiftHeartBeatConfig?
    private var timer: Timer?
    
    public func getHeartBeatStatus() -> TDSwiftHeartBeatStatus {
        return timer == nil ? TDSwiftHeartBeatStatus.terminated : TDSwiftHeartBeatStatus.activated
    }
    
    public func config(config: TDSwiftHeartBeatConfig) {
        self.config = config
    }
    
    public func start() -> Bool {
        // Enable location service
        if (!startReceivingLocationChanges()) { return false }
        
        // If not configured, return false
        guard let config = config else { return false }
        
        // Invalidate previous timer
        if timer != nil { timer!.invalidate() }
        
        // Schedule new timer
        timer = Timer(timeInterval: config.timeInterval, target: self, selector: #selector(self.sendRequest), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
        
        // Result
        return true
    }
    
    public func stop() {
        // Pause location updating
        stopReceivingLocationChanges()
        
        // Invalidate timer if exists
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    private func startReceivingLocationChanges() -> Bool {
        // Service permission
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways { return false }
        
        // Service availability
        if !CLLocationManager.locationServicesEnabled() { return false }
        
        // Configure and start the service
        HMLocationManager.shared.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        HMLocationManager.shared.locationManager.distanceFilter = 10.0  // In meters.
        HMLocationManager.shared.locationManager.delegate = self
        HMLocationManager.shared.locationManager.startUpdatingLocation()
        
        // Enabled location service successfully
        return true
    }
    
    private func stopReceivingLocationChanges() {
        HMLocationManager.shared.locationManager.stopUpdatingLocation()
    }
    
    @objc private func sendRequest() {
        // Request info
        guard let config = self.config else { return }
        
        // Run selector
        config.action()
    }
}

extension TDSwiftHeartBeat: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        HMLocationManager.shared.cacheLocation(coordinate: locations.last!.coordinate)
    }
}
