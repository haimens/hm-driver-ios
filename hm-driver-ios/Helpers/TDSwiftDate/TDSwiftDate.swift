import Foundation

class TDSwiftDate {
    static func utcTimeStringToDate(timeString: String, withFormat format: String) -> Date? {
        // UTC date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Local date
        return dateFormatter.date(from: timeString)
    }
    
    static func dateToLocalTimeString(date: Date, withFormat format: String) -> String? {
        // Date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = format
        
        // Date string
        let dateString = dateFormatter.string(from: date)
        return dateString.count <= 0 ? nil : dateString
    }
    
    static func utcTimeStringToLocalTimeString(timeString: String, withFormat format: String, outputFormat: String) -> String? {
        // UTC time string to date object
        guard let date = utcTimeStringToDate(timeString: timeString, withFormat: format) else { return nil }
        
        print("date \(date)")
        
        // Date to output time string
        return dateToLocalTimeString(date: date, withFormat: outputFormat)
    }
}
