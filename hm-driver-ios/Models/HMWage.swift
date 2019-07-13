import Foundation

class HMWage {
    static func getAllWages(query: [String:Any]?, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "GET", endpoint: "/api/v0/wage/all/detail/driver", query: query, body: nil, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }
}
