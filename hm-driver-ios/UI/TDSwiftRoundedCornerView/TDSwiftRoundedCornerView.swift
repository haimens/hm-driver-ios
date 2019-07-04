  import UIKit
  
  public class TDSwiftRoundedCornerView: UIView {
    public var cornerRedius = 12.0 {
        didSet { redrawCorners() }
    }
    public var roundedCorners: UIRectCorner = [.allCorners] {
        didSet { redrawCorners() }
    }
    
    private func redrawCorners() {
        // Shape layer
        let roundedCornerMaskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: roundedCorners, cornerRadii: CGSize(width: cornerRedius, height: cornerRedius))
        let shape = CAShapeLayer()
        shape.path = roundedCornerMaskPath.cgPath
        
        // Apply
        self.layer.mask = shape
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        redrawCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        redrawCorners()
    }
  }
