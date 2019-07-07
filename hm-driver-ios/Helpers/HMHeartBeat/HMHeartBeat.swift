import Foundation

public class HMHeartBeat {
    // Config heart beat
    private init() {
        TDSwiftHeartBeat.shared.config(config: TDSwiftHeartBeatConfig(timeInterval: 5.0, action: {
            // TODO!!!!!!!!!!!!!!!!!!!!!!!! CONFIG HEART BEAT
            print("砰砰！")
        }))
    }
    
    // Singleton instance
    public static let shared = HMHeartBeat()
    
    public func start() {
        _ = TDSwiftHeartBeat.shared.start()
    }
    
    public func stop() {
        TDSwiftHeartBeat.shared.stop()
    }
}
