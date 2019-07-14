import Foundation

struct HMAuth: Decodable {
    let user_token: String
    let instance_token: String
    let logo_path: String
    let name: String
    let driver_key: String
    let img_path: String
    let realm_token: String
    let email: String
    let isValid: Bool
    let username: String
    let icon_path: String
    let driver_token: String
    let cell: String
    let company_name: String
    
    init?(data: [String: Any]) {
        if let user_token = data["user_token"] as? String { self.user_token = user_token } else { return nil }
        if let instance_token = data["instance_token"] as? String { self.instance_token = instance_token } else { return nil }
        if let logo_path = data["logo_path"] as? String { self.logo_path = logo_path } else { return nil }
        if let name = data["name"] as? String { self.name = name } else { return nil }
        if let driver_key = data["driver_key"] as? String { self.driver_key = driver_key } else { return nil }
        if let img_path = data["img_path"] as? String { self.img_path = img_path } else { return nil }
        if let realm_token = data["realm_token"] as? String { self.realm_token = realm_token } else { return nil }
        if let email = data["email"] as? String { self.email = email } else { return nil }
        if let isValid = data["isValid"] as? Bool { self.isValid = isValid } else { return nil }
        if let username = data["username"] as? String { self.username = username } else { return nil }
        if let icon_path = data["icon_path"] as? String { self.icon_path = icon_path } else { return nil }
        if let driver_token = data["driver_token"] as? String { self.driver_token = driver_token } else { return nil }
        if let cell = data["cell"] as? String { self.cell = cell } else { return nil }
        if let company_name = data["company_name"] as? String { self.company_name = company_name } else { return nil }
    }
}
