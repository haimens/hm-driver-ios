import Foundation
import UIKit

public enum HMBasicButtonState {
    case enabled
    case disabled
}

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
    
    public func changeButtonState(to state: HMBasicButtonState) {
        switch state {
        case .enabled:
            self.isEnabled = true
            self.alpha = 1.0
        case .disabled:
            self.isEnabled = false
            self.alpha = 0.5
        }
    }
}
