import Foundation

class HMDriver {
    static func modifyDriverDetail(body: [String:Any]?, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "PATCH", endpoint: "/api/v0/driver/detail", query: nil, body: body, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }
    
    static func registerLocation(body: [String:Any]?, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "POST", endpoint: "/api/v0/driver/location", query: nil, body: body, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }
}
