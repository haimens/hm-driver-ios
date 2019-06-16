import Foundation
import UIKit

public struct TDSwiftSpinnerConfig {
    let backgroundColor: UIColor
    let backgroundWidth: CGFloat
    let backgroundCornerRadius: CGFloat
    let backgroundAlpha: CGFloat
    let indicatorColor: UIColor
}

public class TDSwiftSpinner {
    // Default spinner config
    public static let defaultConfig: TDSwiftSpinnerConfig = TDSwiftSpinnerConfig(backgroundColor: .black,
                                                                                 backgroundWidth: 80.0,
                                                                                 backgroundCornerRadius: 10.0,
                                                                                 backgroundAlpha: 0.7,
                                                                                 indicatorColor: .white)
    
    // Instance properties
    public var config: TDSwiftSpinnerConfig
    public var viewController: UIViewController
    private var blockingView: UIView!
    
    // Initializer
    public init(viewController: UIViewController, config: TDSwiftSpinnerConfig = TDSwiftSpinner.defaultConfig) {
        // Instance properties
        self.viewController = viewController
        self.config = config
    }
    
    // Show spinner
    public func show() {
        // Setup views if view instance not created
        if self.blockingView == nil { setupViews() }
        
        // Add spinner to vc
        viewController.view.addSubview(blockingView)
    }
    
    // Hide spinner
    public func hide() {
        // Return if view not created
        if self.blockingView == nil { return }
        
        // Hide spinner
        self.blockingView.removeFromSuperview()
    }
    
    // Setup all spinner views
    private func setupViews() {
        // Blocking view
        blockingView = UIView(frame: CGRect(origin: viewController.view.frame.origin, size: viewController.view.frame.size))
        blockingView.backgroundColor = .clear
        
        // Background view
        let backgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: config.backgroundWidth, height: config.backgroundWidth)))
        backgroundView.center = blockingView.center
        backgroundView.backgroundColor = config.backgroundColor
        backgroundView.layer.cornerRadius = config.backgroundCornerRadius
        backgroundView.clipsToBounds = true
        backgroundView.alpha = config.backgroundAlpha
        blockingView.addSubview(backgroundView)
        
        // Spinner
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.center = blockingView.convert(blockingView.center, to: backgroundView)
        spinner.color = config.indicatorColor
        spinner.startAnimating()
        backgroundView.addSubview(spinner)
    }
}
