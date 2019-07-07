import Foundation
import UIKit

class HMTripDetailBGView: TDSwiftRoundedCornerView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupAppearance()
    }
    
    private func setupAppearance() {
        // Rounded corners
        self.cornerRedius = 7.0
        self.roundedCorners = [.topLeft, .topRight]
    
        // Shadow
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
    }
}
