import UIKit

public class TDSwiftIconCircleButton: UIButton {
    @IBInspectable
    public var iconImage: UIImage = UIImage()
    private var iconImageView: UIImageView!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        updateAppearance()
    }
    
    public func updateAppearance() {
        // Remove old sublayers
        self.layer.sublayers?.removeAll()
        
        // Shape layer
        let roundedCornerMaskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: self.frame.width / 2, height: self.frame.width / 2))
        let shape = CAShapeLayer()
        shape.path = roundedCornerMaskPath.cgPath
        
        // Shape and layer properties
        shape.fillColor = self.backgroundColor?.cgColor
        shape.frame = layer.bounds
        layer.backgroundColor = UIColor.clear.cgColor
        
        // Apply
        self.layer.insertSublayer(shape, at: 0)
        
        // Shadow
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
        
        // Icon image view
        iconImageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 16.0, height: 16.0)))
        iconImageView.image = iconImage
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        if iconImageView.superview == nil {
            self.addSubview(iconImageView)
        }
    }
}
