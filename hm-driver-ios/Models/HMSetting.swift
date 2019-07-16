import Foundation

class HMSetting {
    static func getSettingDetail(withKey key: String, completion: (([String: Any]?, Error?)->Void)?) {
        DriverConn.request(method: "GET", endpoint: "/api/v0/setting/detail/key", query: ["setting_key": key], body: nil, headers: nil) { (result, error) in
            completion?(result, error)
        }
    }
}
