import Foundation
import UIKit

public enum HMBasicButtonState {
    case enabled
    case disabled
}

class HMBasicButton: TDSwiftBasicButton {
    public init(frame: CGRect, iconImage icon: UIImage?) {
        super.init(frame: frame)
        setupHMBasicAppearance(iconImage: icon)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupHMBasicAppearance(iconImage: nil)
    }

    private func setupHMBasicAppearance(iconImage icon: UIImage?) {
        self.backgroundColor = CONST.UI.THEME_COLOR
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        
        // Setup icon if available
        if let icon = icon {
            let iconImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 14.0, height: 14.0)))
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.image = icon
            iconImageView.center = CGPoint(x: 22.0, y: self.bounds.midY)
            self.addSubview(iconImageView)
        }
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
