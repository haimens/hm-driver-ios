import Foundation
import UIKit

protocol TDSwiftSegmentedControlDelegate: class {
    func itemSelected(atIndex index: Int)
}

public class TDSwiftSegmentedControl: UIView {
    // Delegate
    weak var delegate: TDSwiftSegmentedControlDelegate?
    
    // Static values
    static private let buttonGap: CGFloat = 2.0
    static private let buttonAnimationDuration: Double = 0.5
    static private let buttonAnimationDamping: CGFloat = 0.75
    
    // Default control config
    static public let defaultConfig = TDSwiftSegmentedControlConfig.init(cornerRadius: 5.0,
                                                                         baseBackgroundColor: UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0),
                                                                         baseLabelFont: UIFont.boldSystemFont(ofSize: 14.0),
                                                                         baseLabelColor: UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.0),
                                                                         buttonColor: .white,
                                                                         buttonLabelFont: UIFont.boldSystemFont(ofSize: 14.0),
                                                                         buttonLabelColor: .black)
    
    // Control properties
    public var cornerRadius: CGFloat! { didSet { self.updateCornerRadius() } }
    
    // Base properties
    public var baseBackgroundColor: UIColor! { didSet { self.backgroundColor = baseBackgroundColor } }
    public var baseLabelFont: UIFont! { didSet { self.updateBaseLabel() } }
    public var baseLabelColor: UIColor! { didSet { self.updateBaseLabel() } }
    
    // Button properties
    public var buttonColor: UIColor! { didSet { self.controlButton.backgroundColor = buttonColor } }
    public var buttonLabelFont: UIFont! { didSet { self.controlButton.titleLabel?.font = buttonLabelFont } }
    public var buttonLabelColor: UIColor! { didSet { self.controlButton.setTitleColor(buttonLabelColor, for: .normal) } }
    
    // Items
    private var baseLabels: [UILabel]!
    private var controlButton: UIButton!
    public var itemTitles: [String]! {
        didSet {
            if itemTitles != nil {
                self.baseLabels = []
                setup()
                configControlProperties(config: TDSwiftSegmentedControl.defaultConfig)
            }
        }
    }
    
    // Computed properties
    private var itemWidth: CGFloat {
        get {
            return itemTitles.isEmpty ? 0.0 : self.frame.width / CGFloat(itemTitles.count)
        }
    }
    
    // State
    var initButtonCenter: CGPoint!
    var initButtonIndex: Int!
    
    public init(frame: CGRect, itemTitles: [String], config: TDSwiftSegmentedControlConfig = TDSwiftSegmentedControl.defaultConfig) {
        super.init(frame: frame)
        self.itemTitles = itemTitles
        self.baseLabels = []
        setup()
        configControlProperties(config: config)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.itemTitles = []
        self.baseLabels = []
    }
    
    private func setup() {
        // Create base labels
        for i in 0..<itemTitles.count {
            // Label property
            let label = UILabel(frame: CGRect(x: CGFloat(i) * itemWidth, y: 0.0, width: itemWidth, height: frame.height))
            label.textAlignment = .center
            label.text = itemTitles[i]
            
            // Tap gesture
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(recognizer:))))
            label.isUserInteractionEnabled = true
            
            // Add label to list and base
            baseLabels.append(label)
            self.addSubview(label)
        }
        
        // Control button
        controlButton = UIButton(frame: CGRect(x: TDSwiftSegmentedControl.buttonGap,
                                               y: TDSwiftSegmentedControl.buttonGap,
                                               width: itemWidth - TDSwiftSegmentedControl.buttonGap * 2,
                                               height: frame.height - TDSwiftSegmentedControl.buttonGap * 2))
        controlButton.setTitle(itemTitles.first, for: .normal)
        controlButton.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.buttonPanned(recognizer:))))
        self.addSubview(controlButton)
    }
    
    private func configControlProperties(config: TDSwiftSegmentedControlConfig) {
        self.cornerRadius = config.cornerRadius
        self.baseBackgroundColor = config.baseBackgroundColor
        self.baseLabelFont = config.baseLabelFont
        self.baseLabelColor = config.baseLabelColor
        self.buttonColor = config.buttonColor
        self.buttonLabelFont = config.baseLabelFont
        self.buttonLabelColor = config.buttonLabelColor
    }
    
    private func updateCornerRadius() {
        // Base corner radius
        self.clipsToBounds = true
        self.layer.cornerRadius = self.cornerRadius
        
        // Control button
        self.controlButton.clipsToBounds = true
        self.controlButton.layer.cornerRadius = self.cornerRadius
    }
    
    private func updateBaseLabel() {
        for label in baseLabels {
            label.font = baseLabelFont
            label.textColor = baseLabelColor
        }
    }
    
    private func nearestIndex(toPoint point: CGPoint) -> Int? {
        // Return nil if the control has no items
        if baseLabels.isEmpty { return nil }
        
        // Find nearest index
        let distances = baseLabels.map { (label) -> CGFloat in abs(label.center.x - point.x) }
        return distances.firstIndex(of: distances.min()!)
    }
    
    @objc private func labelTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended,
            let tappedLabel = recognizer.view as? UILabel,
            let tappedIndex = baseLabels.firstIndex(of: tappedLabel) {
            moveButtonToItem(atIndex: tappedIndex, callDelegate: true)
        }
    }
    
    @objc private func buttonPanned(recognizer: UIPanGestureRecognizer) {
        // Cancel if item list empty
        if baseLabels.isEmpty { return }
        
        switch recognizer.state {
        case .began:
            // Init button location
            initButtonCenter = controlButton.center
            initButtonIndex = nearestIndex(toPoint: controlButton.center)
            
            if let nearestIndex = nearestIndex(toPoint: controlButton.center) {
                // Control button init state
                initButtonIndex = nearestIndex
            } else {
                // Cancel gesture
                recognizer.isEnabled = false
                recognizer.isEnabled = true
            }
        case .changed:
            // Translation since beginning
            let translation = recognizer.translation(in: self)
            
            // New button x value, with min and max limitation
            let newX = max(min(initButtonCenter.x + translation.x, baseLabels.last!.center.x), baseLabels.first!.center.x)
            
            // Move button
            controlButton.center = CGPoint(x: newX, y: controlButton.center.y)
        case .ended, .failed, .cancelled:
            if let nearestIndex = nearestIndex(toPoint: controlButton.center) {
                moveButtonToItem(atIndex: nearestIndex, callDelegate: nearestIndex != initButtonIndex)
            } else {
                moveButtonToItem(atIndex: initButtonIndex, callDelegate: false)
            }
            
        default: break
        }
    }
    
    public func moveButtonToItem(atIndex index: Int, callDelegate: Bool) {
        // Index invalid
        if (index < 0 || index > baseLabels.count - 1) { return }
        
        // Call delegate method
        if callDelegate { self.delegate?.itemSelected(atIndex: index) }
        
        // Animate button
        UIView.animate(withDuration: TDSwiftSegmentedControl.buttonAnimationDuration, delay: 0.0, usingSpringWithDamping: TDSwiftSegmentedControl.buttonAnimationDamping, initialSpringVelocity: 0.0, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
            self.controlButton.setTitle(self.itemTitles[index], for: .normal)
            self.controlButton.center = self.baseLabels[index].center
        })
    }
}
