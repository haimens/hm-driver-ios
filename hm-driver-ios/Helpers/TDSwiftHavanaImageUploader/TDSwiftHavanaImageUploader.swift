import UIKit

enum TDSwiftHavanaImageType: String {
    case logo = "logo"
    case avatar = "avatar"
    case icon = "icon"
}

struct TDSwiftHavanaImageUploadResult {
    let imagePath: String?
    let errorMessage: String?
}

class TDSwiftHavanaImageUploader {
    private init() {}
    static let shared = TDSwiftHavanaImageUploader()
    
    func upload(image: UIImage, imageType: TDSwiftHavanaImageType, completion: (([String: Any]?, Error?)->Void)?) {
        // Havana avatar url
        let url = URL(string: "https://image.od-havana.com/api/v0/\(imageType.rawValue)/base64")
        
        // Compress image
        let compressedImage = UIImage(data: image.jpegData(compressionQuality: 0.1)!)!
        let compressedData = compressedImage.jpegData(compressionQuality: 0.1)!
        
        // Request
        let session = URLSession.shared
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        
        // Authentication
        let magicNum = "\(Int.random(in: 0...9))"
        urlRequest.setValue(ENV.AUTH.APP_TOKEN, forHTTPHeaderField: "app_token")
        urlRequest.setValue(magicNum, forHTTPHeaderField: "magic_num")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Request body
        let json: [String: Any] = ["image_data": "data:image/jpeg;base64,\(compressedData.base64EncodedString())"]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        
        // Signature
        let signature = TDSwiftHash.md5("\(magicNum)POST/api/v0/\(imageType.rawValue)/base64\(String(data: jsonData, encoding: .utf8)!.replacingOccurrences(of: "\\/", with: "/"))\(ENV.AUTH.APP_TOKEN)\(ENV.AUTH.APP_KEY)")
        urlRequest.setValue(signature, forHTTPHeaderField: "signature")
        
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: jsonData, completionHandler: { responseData, response, error in
            // Parsing
            if let responseData = responseData,
                let jsonData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments),
                let json = jsonData as? [String: Any] {
                completion?(json, error)
            } else {
                completion?(nil, error)
            }
        }).resume()
    }
    
    // Handle upload response
    public static func handleResponse(responseData: [String: Any]?, error: Error?) -> TDSwiftHavanaImageUploadResult {
        // Handle request error
        if let error = error {
            // Default
            var errorMessage = "Unknown error"
            
            // Request error
            if let error = error as? URLError {
                if error.code == URLError.Code.notConnectedToInternet {
                    errorMessage = "No internet connection"
                } else if error.code == URLError.Code.timedOut {
                    errorMessage = "Request timed out"
                } else if error.code == URLError.Code.cannotConnectToHost {
                    errorMessage = "Could not connect to the server"
                }
            }
            
            // Result
            return TDSwiftHavanaImageUploadResult(imagePath: nil, errorMessage: errorMessage)
        }
        
        // Handle response
        if let responseData = responseData {
            // Image path
            if let payload = responseData["payload"] as? [String:Any], let imagePath = payload["image_path"] as? String {
                return TDSwiftHavanaImageUploadResult(imagePath: imagePath, errorMessage: nil)
            }
            
            // Handle havana image error
            if let message = responseData["message"] as? String {
                return TDSwiftHavanaImageUploadResult(imagePath: nil, errorMessage: message)
            }
            
            // Response invalid
            return TDSwiftHavanaImageUploadResult(imagePath: nil, errorMessage: "Server response invalid")
        }
        
        // No input
        return TDSwiftHavanaImageUploadResult(imagePath: nil, errorMessage: nil)
    }
}
