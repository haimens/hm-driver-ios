import Foundation
import UIKit

class HMTripDetailPopover: TDSwiftPopover {
    init() {
        // Menu items
        let popoverItems = [
            TDSwiftPopoverItem(iconImage: #imageLiteral(resourceName: "conversation"), titleText: "Text Customer"),
            TDSwiftPopoverItem(iconImage: #imageLiteral(resourceName: "phone"), titleText: "Call Customer"),
            TDSwiftPopoverItem(iconImage: #imageLiteral(resourceName: "phone"), titleText: "Call Dispatch Center"),
            TDSwiftPopoverItem(iconImage: #imageLiteral(resourceName: "placeholder"), titleText: "Sharing Location"),
            TDSwiftPopoverItem(iconImage: #imageLiteral(resourceName: "stop"), titleText: "Stop Sharing Location")
        ]
        
        // Popover instance
        super.init(config: TDSwiftPopoverConfig(backgroundColor: UIColor(red:0.06, green:0.03, blue:0.42, alpha:1.0),
                                                                   size: CGSize(width: 195.0, height: 222.0),
                                                                   items: popoverItems,
                                                                   itemTitleColor: .white,
                                                                   itemTitleFont: UIFont.systemFont(ofSize: 12.0, weight: .medium)))
    }
}
