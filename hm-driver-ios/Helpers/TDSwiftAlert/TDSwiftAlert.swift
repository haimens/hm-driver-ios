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
    
    static func showSingleButtonAlertWithCancelWithTextAlignment(title: String, message: String, messageAlignment: NSTextAlignment, actionBtnTitle: String, cancelBtnTitle: String, presentVC: UIViewController, btnAction: (() -> Void)? ) {
        
        // Message alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = messageAlignment
        let messageText = NSMutableAttributedString(
            string: message,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        
        // Alert instance
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.setValue(messageText, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: actionBtnTitle, style: .default, handler: { (action) in btnAction?() }))
        alert.addAction(UIAlertAction(title: cancelBtnTitle, style: .cancel, handler: nil))
        
        // Present alert
        presentVC.present(alert, animated: true, completion: nil)
    }
    
    static func showSingleButtonAlertWithCancelWithAttributedMessage(title: String, message: NSAttributedString, messageAlignment: NSTextAlignment, actionBtnTitle: String, cancelBtnTitle: String, presentVC: UIViewController, btnAction: (() -> Void)? ) {
        
        // Alert instance
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.setValue(message, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: actionBtnTitle, style: .default, handler: { (action) in btnAction?() }))
        alert.addAction(UIAlertAction(title: cancelBtnTitle, style: .cancel, handler: nil))
        
        // Present alert
        presentVC.present(alert, animated: true, completion: nil)
    }
}
