import Foundation
import UIKit

enum HMTripDetailPopoverVerticalPosition {
    case UP
    case DOWN
}

enum HMTripDetailPopoverHorizontalPosition {
    case LEFT
    case RIGHT
    case MIDDLE
}

enum HMTripDetailPopoverHorizontalDirection {
    case LEFT
    case RIGHT
}

enum HMTripDetailPopoverAnimationType {
    case show
    case hide
}

struct HMTripDetailPopoverPosition {
    let vertical: HMTripDetailPopoverVerticalPosition
    let horizontal: HMTripDetailPopoverHorizontalPosition
}

public struct HMTripDetailPopoverInfo {
    public let customerImageURLString: String?
    public let customerName: String?
    public let customerCell: String?
}

public class HMTripDetailPopover: NSObject {
    // Info
    var customerCell: String?
    
    // Static values
    static private let defaultPopoverPadding: CGFloat = 10.0
    static private let defaultArrowHeight: CGFloat = 10.0
    
    // Popover properties
    let backgroundColor: UIColor
    let size: CGSize
    
    // Popover references
    var popoverBaseView: UIView!
    var bgView: UIView!
    var scalePointInBaseView: CGPoint!
    
    // Popover state
    var isPresenting: Bool {
        get {
            return bgView != nil && bgView.superview != nil
        }
    }
    
    public override init()
    {
        self.backgroundColor = .white
        self.size = CGSize(width: 300, height: 265)
    }
    
    public func present(onView view: UIView, atPoint point: CGPoint, withInfo info: HMTripDetailPopoverInfo) {
        // Popover frame
        let popoverFrame = getPopoverFrame(baseView: view, presentingPoint: point)
        
        // BG View
        bgView = UIView(frame: view.frame)
        bgView.backgroundColor = .clear
        let tapToDismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopover(sender:)))
        tapToDismissGesture.delegate = self
        bgView.addGestureRecognizer(tapToDismissGesture)
        
        // Popover base view
        popoverBaseView = UIView(frame: popoverFrame)
        popoverBaseView.backgroundColor = self.backgroundColor
        popoverBaseView.layer.cornerRadius = 5.0
        
        // Popover arrow
        let verticalPosition = getPopoverVerticalPosition(baseView: view, presentingPoint: point)
        let pointInBaseView = view.convert(point, to: popoverBaseView)
        scalePointInBaseView = pointInBaseView
        if (verticalPosition == .DOWN) {
            TDSwiftShape.drawTriangle(onView: popoverBaseView,
                                      atPoint: CGPoint(x: pointInBaseView.x, y: pointInBaseView.y + 7.0),
                                      width: 21.0,
                                      height: 13.0,
                                      radius: 2.0,
                                      lineWidth: 0.0,
                                      strokeColor: backgroundColor.cgColor,
                                      fillColor: backgroundColor.cgColor,
                                      rotateAngle: 0.0)
        } else if (verticalPosition == .UP) {
            TDSwiftShape.drawTriangle(onView: popoverBaseView,
                                      atPoint: CGPoint(x: pointInBaseView.x, y: pointInBaseView.y - 7.0),
                                      width: 21.0,
                                      height: 13.0,
                                      radius: 2.0,
                                      lineWidth: 0.0,
                                      strokeColor: backgroundColor.cgColor,
                                      fillColor: backgroundColor.cgColor,
                                      rotateAngle: CGFloat(Double.pi))
        }
        
        // Stack views
        view.addSubview(bgView)
        bgView.addSubview(popoverBaseView)
        
        // Customer image view
        let customerImageView = TDSwiftSpinnerImageView(frame: CGRect(origin: .zero, size: CGSize(width: 48.0, height: 48.0)))
        customerImageView.layer.cornerRadius = customerImageView.frame.width / 2
        customerImageView.clipsToBounds = true
        customerImageView.center = CGPoint(x: popoverBaseView.bounds.midX, y: 20 + 20 + 10)
        customerImageView.contentMode = .scaleAspectFill
        popoverBaseView.addSubview(customerImageView)
        // Render image
        if let customerImageURLString = info.customerImageURLString {
            customerImageView.showSpinner()
            TDSwiftImageManager.getImage(imageURLString: customerImageURLString, imageType: .TDSwiftCacheImage, completion: { (data, error) in
                DispatchQueue.main.async {
                    if let data = data { customerImageView.image = UIImage(data: data) }
                    customerImageView.hideSpinner()
                }
            })
        }
        
        // Customer name label
        let customerNameLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 280.0, height: 15.0)))
        customerNameLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        customerNameLabel.text = info.customerName ?? "N/A"
        customerNameLabel.textAlignment = .center
        customerNameLabel.textColor = UIColor(red:0.20, green:0.20, blue:0.36, alpha:1.0)
        customerNameLabel.center = CGPoint(x: popoverBaseView.frame.width / 2, y: customerImageView.frame.maxY + 25)
        popoverBaseView.addSubview(customerNameLabel)
        
        // Call customer button
        let callCustomerBtn = HMBasicButton(frame: CGRect(origin: .zero, size: CGSize(width: 250.0, height: 46)), iconImage: #imageLiteral(resourceName: "call-icon"))
        callCustomerBtn.setTitle("Call Customer", for: .normal)
        callCustomerBtn.center = CGPoint(x: popoverBaseView.frame.width / 2, y: customerNameLabel.frame.maxY + 50)
        popoverBaseView.addSubview(callCustomerBtn)
        if let customerCell = info.customerCell {
            self.customerCell = customerCell
            callCustomerBtn.changeButtonState(to: .enabled)
        } else {
            callCustomerBtn.changeButtonState(to: .disabled)
        }
        
        // Call dispatch button
        let callDispatchBtn = HMBasicButton(frame: CGRect(origin: .zero, size: CGSize(width: 250.0, height: 46)), iconImage: #imageLiteral(resourceName: "support-icon-1"))
        callDispatchBtn.backgroundColor = UIColor(red:0.99, green:0.49, blue:0.37, alpha:1.0)
        callDispatchBtn.setTitle("Call Dispatch Center", for: .normal)
        callDispatchBtn.center = CGPoint(x: popoverBaseView.frame.width / 2, y: callCustomerBtn.frame.maxY + 20 + 23)
        popoverBaseView.addSubview(callDispatchBtn)
        if HMGlobal.shared.isDispatchCellAvailable() {
            callDispatchBtn.changeButtonState(to: .enabled)
        } else {
            callDispatchBtn.changeButtonState(to: .disabled)
        }
        
        // Animate popover
        animatePopover(animationType: .show)
    }
    
    public func dismiss() {
        if (isPresenting) {
            animatePopover(animationType: .hide)
        }
    }
    
    @objc private func dismissPopover(sender: UITapGestureRecognizer) {
        animatePopover(animationType: .hide)
    }
    
    func animatePopover(animationType type: HMTripDetailPopoverAnimationType) {
        // Transforms
        var fromTransform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        var toTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        var animationDamping: CGFloat = 0.75
        if type == .hide {
            fromTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            toTransform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            animationDamping = 1.0
        }
        
        // Animate popup
        let baseViewFrame = popoverBaseView.frame
        popoverBaseView.layer.anchorPoint = CGPoint(x: scalePointInBaseView.x / popoverBaseView.frame.width, y: scalePointInBaseView.y / popoverBaseView.frame.height)
        popoverBaseView.frame = baseViewFrame
        popoverBaseView.transform = fromTransform
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: animationDamping, initialSpringVelocity: 0.0, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
            self.popoverBaseView.transform = toTransform
        } , completion: { (result) in
            if (type == .hide) {
                self.bgView.removeFromSuperview()
            }
        })
    }
    
    // Calculate popover frame
    private func getPopoverFrame(baseView view: UIView, presentingPoint point: CGPoint) -> CGRect {
        // Tempory x y values
        var x: CGFloat = -1.0
        var y: CGFloat = -1.0
        
        // Get popover position
        let position = HMTripDetailPopoverPosition(vertical: getPopoverVerticalPosition(baseView: view, presentingPoint: point),
                                              horizontal: getPopoverHorizontalPosition(baseView: view, presentingPoint: point))
        
        // Calculate y value
        if position.vertical == .UP {
            y = point.y - HMTripDetailPopover.defaultArrowHeight - self.size.height
        } else if position.vertical == .DOWN {
            y = point.y + HMTripDetailPopover.defaultArrowHeight
        }
        
        // Calculate x value
        if (position.horizontal == .MIDDLE) {
            x = point.x - self.size.width / 2
        } else if (position.horizontal == .LEFT) {
            x = view.frame.width - HMTripDetailPopover.defaultPopoverPadding - self.size.width
        } else if (position.horizontal == .RIGHT) {
            x = HMTripDetailPopover.defaultPopoverPadding
        }
        
        // Popover frame
        return CGRect(origin: CGPoint(x: x, y: y), size: self.size)
    }
    
    // Calculate popover veritical position
    private func getPopoverVerticalPosition(baseView view: UIView, presentingPoint point: CGPoint) -> HMTripDetailPopoverVerticalPosition {
        if point.y >= view.frame.height / 2 {
            return .UP
        } else {
            return .DOWN
        }
    }
    
    // Calculate popover horizontal position
    private func getPopoverHorizontalPosition(baseView view: UIView, presentingPoint point: CGPoint) -> HMTripDetailPopoverHorizontalPosition {
        if (isEnoughSpace(onDirection: .LEFT, baseView: view, presentingPoint: point) && isEnoughSpace(onDirection: .RIGHT, baseView: view, presentingPoint: point)
            || !isEnoughSpace(onDirection: .LEFT, baseView: view, presentingPoint: point) && !isEnoughSpace(onDirection: .RIGHT, baseView: view, presentingPoint: point)) {
            return .MIDDLE
        }
        
        if (isEnoughSpace(onDirection: .LEFT, baseView: view, presentingPoint: point)) {
            return .LEFT
        } else {
            return .RIGHT
        }
    }
    
    // Wheather enough space on direction
    private func isEnoughSpace(onDirection direction: HMTripDetailPopoverHorizontalDirection, baseView view: UIView, presentingPoint point: CGPoint) -> Bool {
        if (direction == .LEFT) {
            return point.x >= HMTripDetailPopover.defaultPopoverPadding + self.size.width / 2
        } else {
            return view.frame.width - point.x >= HMTripDetailPopover.defaultPopoverPadding + self.size.width / 2
        }
    }
}
