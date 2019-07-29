import UIKit

public class HMAmountButton: TDSwiftRoundedIconGradientButton {
    public var amountLabel: UILabel!
    
    public init(frame: CGRect) {
        super.init(frame: frame, config: TDSwiftRoundedIconGradientButtonConfig(iconImage: #imageLiteral(resourceName: "moneybag-icon"),
                                                                                gradientColorA: UIColor(red:0.10, green:0.11, blue:0.30, alpha:1.0),
                                                                                gradientColorB: UIColor(red:0.10, green:0.11, blue:0.30, alpha:1.0),
                                                                                gradientAX: 0,
                                                                                gradientAY: 0.5,
                                                                                gradientBX: 1,
                                                                                gradientBY: 0.5,
                                                                                text: "Amount Due",
                                                                                textColor: .white,
                                                                                action: {}))
        
        // Amount label
        amountLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: self.bounds.width - 40.0, height: 15.0)))
        amountLabel.textAlignment = .right
        amountLabel.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        amountLabel.textColor = .white
        amountLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        amountLabel.text = "$ -"
        self.addSubview(amountLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("INIT HMRoundedIconGradientButton FROM IB IS FORBIDDEN")
    }
}
