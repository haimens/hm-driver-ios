import Foundation

class HMSms {
    static func sendSMS(withCustomerToken customerToken: String, body: [String:Any]?, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "POST", endpoint: "/api/v0/sms/send/customer/\(customerToken)", query: nil, body: body, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }
    
    static func sendSMSToDispatch(withCustomerToken customerToken: String, body: [String:Any]?, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "POST", endpoint: "/api/v0/sms/send/dispatch/\(customerToken)", query: nil, body: body, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }
    
    static func getAllSMS(withCustomerToken customerToken: String, query: [String:Any]?, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "GET", endpoint: "/api/v0/sms/all/detail/customer/\(customerToken)", query: query, body: nil, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }
}
