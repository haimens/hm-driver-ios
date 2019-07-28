import Foundation
import UIKit

class TDSwiftMutableParagraphStyle {
    static func getStyle(WithAlignment alignment: NSTextAlignment) -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        return paragraphStyle
    }
}
