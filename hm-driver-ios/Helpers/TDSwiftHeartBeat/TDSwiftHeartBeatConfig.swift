import Foundation

public struct TDSwiftHeartBeatConfig {
    let timeInterval: TimeInterval
    let action: () -> Void
}
