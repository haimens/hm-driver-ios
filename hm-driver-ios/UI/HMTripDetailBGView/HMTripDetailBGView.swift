import Foundation
import UIKit

class HMTripDetailBGView: TDSwiftRoundedCornerView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAppearance()
    }
    
    private func setupAppearance() {
        // Rounded corners
        self.cornerRedius = 7.0
        self.roundedCorners = [.topLeft, .topRight]
    
        // Shadow
//        self.layer.shadowRadius = 5
        
        self.layer.shadowColor = UIColor.red.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = .init(width: 0, height: -10)
        self.layer.shadowRadius = 1.0
        self.clipsToBounds = false
    }
}
