import Foundation

class HMTrip {
    static func getAllActiveTrips(query: [String:Any]?, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "GET", endpoint: "/api/v0/trip/all/active/driver", query: query, body: nil, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }
    
    static func getAllTrips(query: [String:Any]?, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "GET", endpoint: "/api/v0/trip/all/detail/driver", query: query, body: nil, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }

    static func getTripDetail(withTripToken tripToken: String, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "GET", endpoint: "/api/v0/trip/detail/\(tripToken)", query: nil, body: nil, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }
}
