import Foundation

enum DriverConnError: Error {
    case responseEmpty
    case responseFormatInvalid
    case responseWithErrorMessage(message: String)
    
    func getErrorMessage() -> String? {
        switch self {
        case let .responseWithErrorMessage(message: message):
            return message
        default:
            return nil
        }
    }
}

class DriverConn {
    static func request(method: String, endpoint: String, query: [String: String]?, body: [String: Any]?, headers: [String: String]?, completion: (([String: Any]?, Error?) -> Void)?) {
        // Auth info
        var authedHeaders = headers
        if TDSwiftHavana.shared.authInfoAvailable() {
            if (authedHeaders != nil) {
                authedHeaders!["user_token"] = TDSwiftHavana.shared.auth!.user_token
                authedHeaders!["instance_token"] = TDSwiftHavana.shared.auth!.instance_token
            } else {
                authedHeaders = ["user_token": TDSwiftHavana.shared.auth!.user_token,
                                 "instance_token": TDSwiftHavana.shared.auth!.instance_token]
            }
        }
        
        // Query
        var queryToUse = ""
        if let query = query {
            queryToUse += "?"
            for (key, value) in query {
                if queryToUse.count > 1 { queryToUse += "&" }
                queryToUse += "\(key)=\(value)"
            }
        }
        
        // Make request
        TDSwiftRequest.request(urlString: "\(ENV.DRIVER.URL)\(endpoint)\(queryToUse)", method: method, body: body, headers: headers, timeOut: CONST.REQUEST.REQUEST_TIME_OUT) { (json, response, error) in
            
            // Handle 403 relogin
            if let requestError = error as? TDSwiftRequestError, let statusCode = requestError.getStatusCode(), statusCode == 403, let errorMessage = json?["message"] as? String, errorMessage == "!!!!!!!!!!!REPLACE THIS!!!!!!!!!!" {
                TDSwiftHavana.shared.renewAuthInfo(completion: { (result, error) in
                    if result {
                        // Resend current request
                        DriverConn.request(method: method, endpoint: endpoint, query: query, body: body, headers: headers, completion: completion)
                    } else if error != nil {
                        completion?(nil, error); return
                    }
                })
                
                // Terminate current request
                return
            }
            
            // Handle request error
            if (error != nil) { completion?(nil, error); return }
            
            // Parse response json
            guard let json = json else { completion?(nil, DriverConnError.responseEmpty); return }
            
            // Handle status false
            guard let status = json["status"] as? Bool else { completion?(nil, DriverConnError.responseFormatInvalid); return }
            if (!status) {
                guard let message = json["message"] as? String else { completion?(nil, DriverConnError.responseFormatInvalid); return }
                completion?(nil, DriverConnError.responseWithErrorMessage(message: message)); return
            }
            
            // Payload
            guard var payload = json["payload"] as? [String: Any] else { completion?(nil, DriverConnError.responseFormatInvalid); return }
            
            // Verify info
            if let verifyInfo = json["verify_info"] as? [String: Any] {
                payload = payload.merging(verifyInfo, uniquingKeysWith: { (first, _) in first })
            }
                        
            // Result
            completion?(payload, nil); return
        }
    }
    
    static func getErrorMessage(error: Error) -> String {
        // DriverConnError
        if let error = error as? DriverConnError {
            switch error {
            case .responseEmpty:
                return "Response empty"
            case .responseFormatInvalid:
                return "Response format invalid"
            case .responseWithErrorMessage:
                return "Response with error message: \(error.getErrorMessage() ?? "Message not found")"
            }
        }
        
        // TDSwiftHavana error handling
        return TDSwiftHavana.getErrorMessage(error: error)
    }
}
