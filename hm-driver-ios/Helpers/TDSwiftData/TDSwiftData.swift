import Foundation

@objc protocol TDSwiftData {
    func loadData()
    func parseData(data: [String : Any])
    @objc optional func alertParseDataFailed()
    @objc optional func purgeData()
}
