import Foundation

class HMSalary {
    static func getAllSalaries(query: [String:Any]?, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "GET", endpoint: "/api/v0/salary/all/detail/driver", query: query, body: nil, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }
}
