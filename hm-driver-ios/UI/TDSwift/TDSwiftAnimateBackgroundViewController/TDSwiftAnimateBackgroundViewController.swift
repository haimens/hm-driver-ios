import UIKit

class TDSwiftAnimateBackgroundViewController: UIViewController {
    var backgroundView: UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateBackground(animateIn: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animateBackground(animateIn: false)
    }
    
    private func animateBackground(animateIn: Bool) {
        guard let presentingViewController = presentingViewController else { return }
        
        if animateIn {
            self.backgroundView = UIView(frame: presentingViewController.view.frame)
            self.backgroundView!.backgroundColor = UIColor(hue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 0.0)
            presentingViewController.view.addSubview(self.backgroundView!)
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseOut], animations: {
                self.backgroundView!.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.6)
            }, completion: nil)
        } else {
            guard let backgroundView = self.backgroundView else { return }
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseOut], animations: {
                backgroundView.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.0)
            }) { (result) in
                if result { backgroundView.removeFromSuperview() }
            }
        }
    }
}
