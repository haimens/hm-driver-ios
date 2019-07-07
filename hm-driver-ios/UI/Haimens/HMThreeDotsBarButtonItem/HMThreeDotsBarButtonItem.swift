import Foundation
import UIKit

public class HMThreeDotsBarButtonItem: UIBarButtonItem {
    public init(target: AnyObject, selector: Selector) {
        super.init()
        
        // Button item properties
        self.title = "● ● ● "
        self.style = .plain
        self.target = target
        self.action = selector
        
        // Button title properties
        self.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 7.0)], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 7.0)], for: .selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
