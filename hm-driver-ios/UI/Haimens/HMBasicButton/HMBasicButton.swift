import Foundation
import UIKit

class HMBasicButton: TDSwiftBasicButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupHMBasicAppearance()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupHMBasicAppearance()
    }

    private func setupHMBasicAppearance() {
        self.backgroundColor = CONST.UI.THEME_COLOR
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
    }
}
