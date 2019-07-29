import Foundation
import UIKit

public class TDSwiftSpinnerImageView: UIImageView {
    // Spinner instance
    private var spinner: UIActivityIndicatorView!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        initSpinner()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initSpinner()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSpinner()
    }
    
    private func initSpinner() {
        spinner = UIActivityIndicatorView(style: .gray)
        spinner.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 40.0, height: 40.0))
        spinner.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        spinner.hidesWhenStopped = true
        self.addSubview(spinner)
    }
    
    public func showSpinner() {
        spinner?.startAnimating()
    }
    
    public func hideSpinner() {
        spinner?.stopAnimating()
    }
}
