import Foundation
import UIKit

public class TDSwiftMapTools {
    public static func showAddressOptions(onViewController vc: UIViewController, withAddress address: String) {
        // Option menu instance
        let optionMenu = UIAlertController(title: "Address", message: address, preferredStyle: .actionSheet)
        optionMenu.view.tintColor = .black
        
        // Menu actions
        let copyAction = UIAlertAction(title: "Copy", style: .default) { (action) in
            // Copy address to clip board
            let pasteboard = UIPasteboard.general
            pasteboard.string = address
        }
        let navigateAction = UIAlertAction(title: "Navigation", style: .default) { (action) in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(copyAction)
        optionMenu.addAction(navigateAction)
        optionMenu.addAction(cancelAction)
        
        // Show option menu
        vc.present(optionMenu, animated: true) {
            
        }
    }
}
