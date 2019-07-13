import Foundation

class HMMoneyUnitConverter {
    static func centToDollar(amountInCent: Int) -> String {
        let amountInDollar = Double(amountInCent) / 100.0 // Cent to dollar
        return String(format: "%.2f", amountInDollar)
    }
    
    static func dollarToCent(amountInDollar: Double) -> Int {
        return Int(round(amountInDollar * 100))
    }
}
