import Foundation
import UIKit

enum TDSwiftRouteDetailViewAddressButtonLocation {
    case upper
    case lower
}

protocol TDSwiftRouteDetailViewDelegate: class {
    func didSelectAddressBtn(atLocation location: TDSwiftRouteDetailViewAddressButtonLocation, button: UIButton)
}

public class TDSwiftRouteDetailView: UIView {
    weak var delegate: TDSwiftRouteDetailViewDelegate?
    
    // Static properties
    static private let defaultLabelFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    static private let defaultAddressFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    static private let defaultLabelColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1.0)
    static private let defaultAddressColor = UIColor.black
    
    // UI elements
    public var upperLabel: UILabel!
    public var lowerLabel: UILabel!
    public var upperAddressBtn: UIButton!
    public var lowerAddressBtn: UIButton!
    
    public init(frame: CGRect, upperLabelText: String, upperAddressText: String, lowerLabelText: String, lowerAddressText: String) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupLabels(upperText: upperLabelText, lowerText: lowerLabelText)
        setupAddressBtns(upperText: upperAddressText, lowerText: lowerAddressText)
        drawShapes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .white
        setupLabels(upperText: "-", lowerText: "-")
        setupAddressBtns(upperText: "-", lowerText: "-")
        drawShapes()
    }
    
    private func setupLabels(upperText: String, lowerText: String) {
        // Upper label
        let upperLabelFrame = CGRect(x: 45.0, y: 8.0, width: self.frame.width - 45.0 - 25.0, height: 14.0)
        upperLabel = UILabel(frame: upperLabelFrame)
        upperLabel.text = upperText
        upperLabel.font = TDSwiftRouteDetailView.defaultLabelFont
        upperLabel.textColor = TDSwiftRouteDetailView.defaultLabelColor
        upperLabel.textAlignment = .left
        
        // Lower label
        let lowerLabelFrame = CGRect(x: 45.0, y: self.frame.height / 2 + 8.0, width: self.frame.width - 45.0 - 25.0, height: 14.0)
        lowerLabel = UILabel(frame: lowerLabelFrame)
        lowerLabel.text = lowerText
        lowerLabel.font = TDSwiftRouteDetailView.defaultLabelFont
        lowerLabel.textColor = TDSwiftRouteDetailView.defaultLabelColor
        lowerLabel.textAlignment = .left
        
        // Add labels to view
        self.addSubview(upperLabel)
        self.addSubview(lowerLabel)
    }
    
    private func setupAddressBtns(upperText: String, lowerText: String) {
        // Upper button
        let upperButtonFrame = CGRect(x: 45.0, y: upperLabel.frame.maxY + 6.0, width: self.frame.width - 45.0 - 25.0, height: 14.0)
        upperAddressBtn = UIButton(type: .system)
        upperAddressBtn.frame = upperButtonFrame
        upperAddressBtn.setTitle(upperText, for: .normal)
        upperAddressBtn.titleLabel?.font = TDSwiftRouteDetailView.defaultAddressFont
        upperAddressBtn.setTitleColor(TDSwiftRouteDetailView.defaultAddressColor, for: .normal)
        upperAddressBtn.titleLabel?.textAlignment = .left
        upperAddressBtn.contentHorizontalAlignment = .left
        upperAddressBtn.showsTouchWhenHighlighted = true
        upperAddressBtn.addTarget(self, action: #selector(self.addressBtnPressed(sender:)), for: .touchUpInside)
        
        // Lower button
        let lowerButtonFrame = CGRect(x: 45.0, y: lowerLabel.frame.maxY + 6.0, width: self.frame.width - 45.0 - 25.0, height: 14.0)
        lowerAddressBtn = UIButton(type: .system)
        lowerAddressBtn.frame = lowerButtonFrame
        lowerAddressBtn.setTitle(lowerText, for: .normal)
        lowerAddressBtn.titleLabel?.font = TDSwiftRouteDetailView.defaultAddressFont
        lowerAddressBtn.setTitleColor(TDSwiftRouteDetailView.defaultAddressColor, for: .normal)
        lowerAddressBtn.titleLabel?.textAlignment = .left
        lowerAddressBtn.contentHorizontalAlignment = .left
        lowerAddressBtn.addTarget(self, action: #selector(self.addressBtnPressed(sender:)), for: .touchUpInside)
        
        // Add buttons to view
        self.addSubview(upperAddressBtn)
        self.addSubview(lowerAddressBtn)
    }
    
    private func drawShapes() {
        // Upper dot
        TDSwiftShape.drawCircle(onView: self, atCenter: CGPoint(x: upperLabel.frame.minX - 11 - 4.5, y: upperLabel.frame.minY + 7.0), redius: 4.5, lineWidth: 1.0, fillColor: UIColor.clear.cgColor, strokeColor: UIColor(red:0.06, green:0.03, blue:0.42, alpha:1.0).cgColor)
        
        // Lower dot
        TDSwiftShape.drawCircle(onView: self, atCenter: CGPoint(x: lowerLabel.frame.minX - 11 - 4.5, y: lowerLabel.frame.minY + 7.0), redius: 4.5, lineWidth: 1.0, fillColor: UIColor(red:0.06, green:0.03, blue:0.42, alpha:1.0).cgColor, strokeColor: UIColor(red:0.06, green:0.03, blue:0.42, alpha:1.0).cgColor)
        
        // Dashed line
        TDSwiftShape.drawDashedLine(onView: self, fromPoint: CGPoint(x: upperLabel.frame.minX - 11 - 4.5, y: upperLabel.frame.minY + 7.0 + 5.0 + 6.0), toPoint: CGPoint(x: lowerLabel.frame.minX - 11 - 4.5, y: lowerLabel.frame.minY + 7.0 - 5.0 - 6.0), lineWidth: 3.0, dashLength: 3.0, dashGap: 3.0, strokeColor: UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0).cgColor)
    }
    
    @objc private func addressBtnPressed(sender: UIButton) {
        if sender == upperAddressBtn {
            delegate?.didSelectAddressBtn(atLocation: .upper, button: sender)
        } else if sender == lowerAddressBtn {
            delegate?.didSelectAddressBtn(atLocation: .lower, button: sender)
        }
    }
}
