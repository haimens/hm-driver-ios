import Foundation
import UIKit

class HMRouteDetailView: TDSwiftRouteDetailView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // View label content
        upperLabel.text = "Pickup Location"
        lowerLabel.text = "Dropoff Location"
    }
}
