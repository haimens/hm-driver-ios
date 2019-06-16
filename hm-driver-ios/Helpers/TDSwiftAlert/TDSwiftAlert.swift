import Foundation
import UIKit

class TDSwiftAlert {
    static func showSingleButtonAlert(title: String, message: String, actionBtnTitle: String, presentVC: UIViewController, btnAction: (() -> Void)? ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionBtnTitle, style: .default, handler: { (action) in btnAction?() }))
        presentVC.present(alert, animated: true, completion: nil)
    }
    
    static func showSingleButtonAlertWithCancel(title: String, message: String, actionBtnTitle: String, cancelBtnTitle: String, presentVC: UIViewController, btnAction: (() -> Void)? ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionBtnTitle, style: .default, handler: { (action) in btnAction?() }))
        alert.addAction(UIAlertAction(title: cancelBtnTitle, style: .cancel, handler: nil))
        presentVC.present(alert, animated: true, completion: nil)
    }    
}
