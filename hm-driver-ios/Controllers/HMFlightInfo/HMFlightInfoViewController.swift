import Foundation
import UIKit

class c: TDSwiftAnimateBackgroundViewController {
    @IBOutlet weak var bgView: TDSwiftRoundedCornerView!
    
    @IBAction func dismissBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupAppearance()
    }
    
    private func setupAppearance() {
        // Background view
        bgView.roundedCorners = [.topLeft, .topRight]
    }
}
