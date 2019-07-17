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
                
        // Date to output time string
        return dateToLocalTimeString(date: date, withFormat: outputFormat)
    }
    
    static func getCurrentLocalTimeString(withFormat format: String) -> String {
        // Date formatter instance
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        // Current date
        let date = Date()
        
        // Time string
        return dateFormatter.string(from: date)
    }
    
    static func getCurrentLocalDate() -> Date {
        return Date()
    }
    
    static func formatDateToDateString(forDate date: Date, withFormat format: String) -> String {
        // Date formatter instance
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        // Format date
        return dateFormatter.string(from: date)
    }
    
    static func getCurrentUTCTimeString(withFormat format: String) -> String {
        // UTC Formatter
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        
        // Formatted string
        return formatter.string(from: Date())
    }
    
    static func getCurrentUTCDate() -> Date? {
        // Date format
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // UTC Formatter
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = dateFormat
        
        // Formatted string
        let dateString = formatter.string(from: Date())
        
        // UTC date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Date object
        return dateFormatter.date(from: dateString) ?? nil
    }
}
