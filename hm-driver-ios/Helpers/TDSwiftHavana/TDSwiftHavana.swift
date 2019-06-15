import Foundation

enum TDSwiftHavanaError: Error {
    case loginResponseInvalid
    case userInfoMissing
}

class TDSwiftHavana {
    // Hide initializer
    private init() {}
    
    // Singleton instance
    static let shared = TDSwiftHavana()
    
    // Permanent storage keys
    private static let accountKey = ENV.AUTH.ACCOUNT_KEY
    private static let keychainService = ENV.AUTH.KEY_CHAIN_SERVICE
    
    // Instance properties
    var userToken: String?
    var instanceToken: String?
    
    // Login account, stored in UserDefaults
    var account: String? {
        get { return UserDefaults.standard.string(forKey: TDSwiftHavana.accountKey) }
        set { if let account = newValue { UserDefaults.standard.set(account, forKey: TDSwiftHavana.accountKey) } }
    }
    
    // Login password, stored in Keychain
    private var password: String? {
        get {
            guard let account = account else { return nil }
            return try? KeychainPasswordItem(service: TDSwiftHavana.keychainService, account: account).readPassword()
        }
        set {
            guard let account = account, let password = newValue else { return }
            try? KeychainPasswordItem(service: TDSwiftHavana.keychainService, account: account).savePassword(password)
        }
    }
    
    // Delete login account and password
    func removeUserInfo() {
        if let account = account {
            let _ = try? KeychainPasswordItem(service: TDSwiftHavana.keychainService, account: account).readPassword()
            UserDefaults.standard.removeObject(forKey: TDSwiftHavana.accountKey)
        }
    }
    
    // Delete current auth info
    func removeAuthInfo() {
        userToken = nil
        instanceToken = nil
    }
    
    // Whether login account and password are available
    func userInfoAvailable() -> Bool {
        return account != nil && password != nil
    }
    
    // Whether auth info are available
    func authInfoAvailable() -> Bool {
        return userToken != nil && instanceToken != nil
    }
    
    // Perform login action
    func login(account: String, password: String, completion: ((Bool, Error?) -> Void)?) {
        DriverConn.request(method: "POST", endpoint: "/api/v0/login", query: nil, body: ["username": account, "passcode": password], headers: nil) { (response, error) in
            // Error handle
            if (error != nil) { completion?(false, error!); return }
            
            // Unwrap loginResponse
            guard let response = response else { completion?(false, TDSwiftHavanaError.loginResponseInvalid); return }
            
            // Parse response
            guard
                let user_token = response["user_token"] as? String,
                let instance_token = response["instance_token"] as? String else {
                    completion?(false, TDSwiftHavanaError.loginResponseInvalid); return
            }
            
            // Save auth info to local
            self.userToken = user_token
            self.instanceToken = instance_token
            
            // Save user info to local
            self.account = account
            self.password = password
            
            // Complete
            completion?(true, nil); return
        }
    }
    
    // Login using saved username and password
    func renewAuthInfo(completion: ((Bool, Error?) -> Void)?) {
        // If user info missing
        if (!userInfoAvailable()) { completion?(false, TDSwiftHavanaError.userInfoMissing); return }
        
        // Login
        login(account: account!, password: password!) { (result, error) in completion?(result, error); return }
    }
    
    static func getErrorMessage(error: Error) -> String {
        // DriverConnError
        if let error = error as? TDSwiftHavanaError {
            switch error {
            case .loginResponseInvalid:
                return "Login response invalid"
            case .userInfoMissing:
                return "User info missing"
            }
        }
        
        // TDSwiftRequest error handling
        return TDSwiftRequest.getErrorMessage(error: error, response: nil)
    }
}
