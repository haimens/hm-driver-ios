import UIKit

@IBDesignable
class TDSwiftGradientView: UIView {
    @IBInspectable var fromColor: UIColor = UIColor.white {
        didSet { updateView() }
    }
    
    @IBInspectable var toColor: UIColor = UIColor.white {
        didSet { updateView() }
    }
    
    @IBInspectable var fromX: Double = 0.0 {
        didSet { updateView() }
    }
    
    @IBInspectable var fromY: Double = 0.0 {
        didSet { updateView() }
    }
    
    @IBInspectable var toX: Double = 0.0 {
        didSet { updateView() }
    }
    
    @IBInspectable var toY: Double = 0.0 {
        didSet { updateView() }
    }
    
    override class var layerClass: AnyClass {
        get { return CAGradientLayer.self }
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [fromColor, toColor].map {$0.cgColor}
        layer.startPoint = CGPoint(x: fromX, y: fromY)
        layer.endPoint = CGPoint (x: toX, y: toY)
    }
}
