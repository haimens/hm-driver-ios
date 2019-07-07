import Foundation

public class TDSwiftHeartBeat {
    // Hide initializer
    private init() {}
    
    // Singleton instance
    public static let shared = TDSwiftHeartBeat()
    
    // Config and timer reference
    private var config: TDSwiftHeartBeatConfig?
    private var timer: Timer?
    
    public func config(config: TDSwiftHeartBeatConfig) {
        self.config = config
    }
    
    public func start() -> Bool {
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
        // Invalidate timer if exists
        if let timer = timer { timer.invalidate() }
    }
    
    @objc private func sendRequest() {
        // Request info
        guard let config = self.config else { return }
        
        // Run selector
        config.action()
    }
}
