import Foundation
import UIKit

public enum TDSwiftMapType {
    case GOOGLE
    case APPLE
}

public class TDSwiftMapTools {
    public static func showAddressOptions(onViewController vc: UIViewController, withAddress address: String, completion: ((Bool, TDSwiftMapType) -> Void)?) {
        // Option menu instance
        let optionMenu = UIAlertController(title: "Address", message: address, preferredStyle: .actionSheet)
        optionMenu.view.tintColor = .black
        
        // Menu actions
        let copyAction = UIAlertAction(title: "Copy", style: .default) { (action) in
            // Copy address to clip board
            let pasteboard = UIPasteboard.general
            pasteboard.string = address
        }
        let navigateAction = UIAlertAction(title: "Navigation", style: .default) { (action) in
            // Show navigation options
            showNavigationOptions(onViewController: vc, withAddress: address, completion: { (result, mapType) in completion?(result, mapType) })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(copyAction)
        optionMenu.addAction(navigateAction)
        optionMenu.addAction(cancelAction)
        
        // Show option menu
        vc.present(optionMenu, animated: true, completion: nil)
    }
    
    public static func showNavigationOptions(onViewController vc: UIViewController, withAddress address: String, completion: ((Bool, TDSwiftMapType) -> Void)?) {
        // Option menu instance
        let optionMenu = UIAlertController(title: "Address", message: address, preferredStyle: .actionSheet)
        optionMenu.view.tintColor = .black
        
        // Menu actions
        let googleAction = UIAlertAction(title: "Navigate by Google Maps", style: .default) { (action) in
            launchGoogleMapsNavigation(withAddress: address, completion: { (result) in completion?(result, .GOOGLE) })
        }
        let appleAction = UIAlertAction(title: "Navigate by Apple Maps", style: .default) { (action) in
            launchAppleMapsNavigation(withAddress: address, completion: { (result) in completion?(result, .APPLE) })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(googleAction)
        optionMenu.addAction(appleAction)
        optionMenu.addAction(cancelAction)
        
        // Show option menu
        vc.present(optionMenu, animated: true, completion: nil)
    }
    
    public static func launchGoogleMapsNavigation(withAddress address: String, completion: ((Bool) -> Void)?) {
        // Process address string
        let processedAddress = (address.trimmingCharacters(in: .whitespacesAndNewlines)).replacingOccurrences(of: " ", with: "+")
        
        // Launch Google Maps
        UIApplication.shared.open(URL(string:"https://www.google.com/maps/dir/?api=1&destination=\(processedAddress)&travelmode=driving")!, options: [:]) { (result) in completion?(result) }
    }
    
    public static func launchAppleMapsNavigation(withAddress address: String, completion: ((Bool) -> Void)?) {
        // Process address string
        let processedAddress = (address.trimmingCharacters(in: .whitespacesAndNewlines)).replacingOccurrences(of: " ", with: "+")
        
        // Launch Apple Maps
        UIApplication.shared.open(URL(string:"http://maps.apple.com/maps?address=\(processedAddress)")!, options: [:]) { (result) in completion?(result) }
    }

}
