import UIKit

public struct TDSwiftRoundedIconGradientButtonConfig {
    let iconImage: UIImage
    let gradientColorA: UIColor
    let gradientColorB: UIColor
    let gradientAX: Double
    let gradientAY: Double
    let gradientBX: Double
    let gradientBY: Double
    let text: String
    let textColor: UIColor
    let action: () -> Void
}

public class TDSwiftRoundedIconGradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    
    @IBInspectable
    public var iconImage: UIImage = UIImage()
    
    @IBInspectable
    public var gradientColorA: UIColor = UIColor(red:0.28, green:0.46, blue:0.90, alpha:1.0)
    
    @IBInspectable
    public var gradientColorB: UIColor = UIColor(red:0.56, green:0.33, blue:0.91, alpha:1.0)
    
    @IBInspectable
    public var gradientAX: Double = 0.0
    
    @IBInspectable
    public var gradientAY: Double = 0.5
    
    @IBInspectable
    public var gradientBX: Double = 1.0
    
    @IBInspectable
    public var gradientBY: Double = 0.5
    
    @IBInspectable
    public var text: String = "N/A" {
        didSet {
            textLabel?.text = text
        }
    }
    
    @IBInspectable
    public var textColor: UIColor = .white
    
    @IBInspectable
    public var buttonEnabled: Bool = true {
        didSet {
            if buttonEnabled {
                enable()
            } else {
                disable()
            }
        }
    }
    
    var textLabel: UILabel!
    
    public var action: () -> Void = {}
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        updateButtonAppearance()
    }
    
    public init(frame: CGRect, config: TDSwiftRoundedIconGradientButtonConfig) {
        super.init(frame: frame)
        
        // Init property
        self.iconImage = config.iconImage
        self.gradientColorA = config.gradientColorA
        self.gradientColorB = config.gradientColorB
        self.gradientAX = config.gradientAX
        self.gradientAY = config.gradientAY
        self.gradientBX = config.gradientBX
        self.gradientBY = config.gradientBY
        self.text = config.text
        self.textColor = config.textColor
        self.action = config.action
        
        updateButtonAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateButtonAppearance()
    }
    
    public func updateButtonAppearance() {
        // Remove old sublayers
        self.layer.sublayers?.removeAll()
        
        // Gradient background
        gradientLayer.frame = bounds
        gradientLayer.colors = [gradientColorA, gradientColorB].map {$0.cgColor}
        gradientLayer.startPoint = CGPoint(x: gradientAX, y: gradientAY)
        gradientLayer.endPoint = CGPoint (x: gradientBX, y: gradientBY)
        self.layer.addSublayer(gradientLayer)
        
        // Shadow
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
        
        // Shape layer
        let roundedCornerMaskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: self.frame.height / 2, height: self.frame.height / 2))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = roundedCornerMaskPath.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.frame = layer.bounds
        layer.backgroundColor = UIColor.clear.cgColor
        gradientLayer.mask = shapeLayer
        
        // Icon
        let iconImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 14.0, height: 14.0)))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = self.iconImage
        iconImageView.center = CGPoint(x: 13.0 + iconImageView.frame.width / 2, y: self.frame.height / 2)
        self.addSubview(iconImageView)
        
        // Text
        textLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: self.bounds.width - iconImageView.frame.maxX - 10.0 - 15.0, height: 15.0)))
        textLabel.center = CGPoint(x: iconImageView.frame.maxX + 10.0 + textLabel.bounds.width / 2, y: self.bounds.height / 2)
        textLabel.textColor = textColor
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textLabel.textAlignment = .left
        textLabel.text = text
        self.addSubview(textLabel)
    }
    
    public func enable() {
        self.isEnabled = true
        self.alpha = 1.0
    }
    
    public func disable() {
        self.isEnabled = false
        self.alpha = 0.5
    }
}
