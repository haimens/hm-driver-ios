import Foundation

class TDSwiftUnitConverter {
    static func centToDollar(amountInCent: Int) -> String {
        let amountInDollar = Double(amountInCent) / 100.0 // Cent to dollar
        return String(format: "%.2f", amountInDollar)
    }
    
    static func dollarToCent(amountInDollar: Double) -> Int {
        return Int(round(amountInDollar * 100))
    }
    
    static func meterToMile(distanceInMeter: Double) -> Double {
        return distanceInMeter / 1609.344
    }
    
    static func secondToMinute(intervalInSecond: Int) -> Float {
        return Float(intervalInSecond) / 60.0
    }
}
