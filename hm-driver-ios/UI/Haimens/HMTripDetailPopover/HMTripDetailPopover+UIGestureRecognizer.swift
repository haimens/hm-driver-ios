import Foundation
import UIKit

extension HMTripDetailPopover: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == bgView
    }
}
