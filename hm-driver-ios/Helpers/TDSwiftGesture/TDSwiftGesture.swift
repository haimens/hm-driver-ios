import Foundation
import UIKit

public class TDSwiftGesture {
    public static func addTapToEndEditingGesture(onView view: UIView) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: TDSwiftGesture.self, action: #selector(TDSwiftGesture.endEditing(sender:))))
    }
    
    @objc private static func endEditing(sender: UITapGestureRecognizer) {
        sender.view?.endEditing(true)
    }
}
