  import Foundation
  import UIKit
  
  public class TDSwiftBasicButton: UIButton {
    // Default colors
    public static let defaultThemeColor = UIColor(red:0.00, green:0.73, blue:0.56, alpha:1.0)
    public static let defaultLabelColor = UIColor.white
    public static let deafultLabelHighlightColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaultAppearance()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDefaultAppearance()
    }
    
    private func setupDefaultAppearance() {
        // Corner redius
        self.clipsToBounds = true
        self.layer.cornerRadius = 6.0
        
        // Background and label color
        self.backgroundColor = TDSwiftBasicButton.defaultThemeColor
        self.setTitleColor(TDSwiftBasicButton.defaultLabelColor, for: .normal)
        self.setTitleColor(TDSwiftBasicButton.deafultLabelHighlightColor, for: .highlighted)
        
        // Label font
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
    }
  }
