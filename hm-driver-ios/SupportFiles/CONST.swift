import Foundation
import UIKit

struct CONST {
    struct REQUEST {
        static let REQUEST_TIME_OUT = 20.0
    }
    
    struct UI {
        static let THEME_COLOR = UIColor(red:0.37, green:0.45, blue:0.89, alpha:1.0)
        static let NOT_AVAILABLE_PLACEHOLDER = "-"
        static let STRING_ATTRIBUTES_LEFT_PARAGRAPH: [NSAttributedString.Key:Any] =
            [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.paragraphStyle: TDSwiftMutableParagraphStyle.getStyle(WithAlignment: .left)
            ]
        static let STRING_ATTRIBUTES_CENTER_PARAGRAPH: [NSAttributedString.Key:Any] =
            [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.paragraphStyle: TDSwiftMutableParagraphStyle.getStyle(WithAlignment: .center)
        ]
        static let STRING_ATTRIBUTES_LEFT_PARAGRAPH_ALARM: [NSAttributedString.Key:Any] =
            [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor: UIColor.red,
                NSAttributedString.Key.paragraphStyle: TDSwiftMutableParagraphStyle.getStyle(WithAlignment: .left)
            ]
    }
    
    struct LOCATION {
        static let LAST_LOCATION_CACHE_KEY = "LAST_LOCATION_CACHE_KEY"
    }
}
