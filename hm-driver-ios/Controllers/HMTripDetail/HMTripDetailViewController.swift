import UIKit

class HMTripDetailViewController: UIViewController {
    // Popover menu
    var popover: TDSwiftPopover!
    
    // Data
    var tripToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) { configNavigationAppearance() }
    
    override func viewWillDisappear(_ animated: Bool) { popover.dismiss() }
    
    private func setupUI() {
        // Navigation appearance
        configNavigationAppearance()
        
        // Menu bar button
        navigationItem.rightBarButtonItem = HMThreeDotsBarButtonItem(target: self, selector: #selector(self.showOptionsMenu(_:)))
        
        // Popover menu
        popover = HMTripDetailPopover()
        popover.delegate = self
    }
    
    @objc private func showOptionsMenu(_ sender: UIBarButtonItem) {
        // Calculate popover origin
        let buttonItemView = self.navigationItem.rightBarButtonItem!.value(forKey: "view") as! UIView
        let buttonItemViewCenter = buttonItemView.convert(buttonItemView.center, to: self.view)
        let popoverOrigin = CGPoint(x: buttonItemViewCenter.x - 5, y: buttonItemViewCenter.y + 10)
        
        // Present popover
        popover.present(onView: self.navigationController!.view, atPoint: popoverOrigin)
    }
    
    private func configNavigationAppearance() {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}

extension HMTripDetailViewController: TDSwiftPopoverDelegate {
    func didSelect(item: TDSwiftPopoverItem, atIndex index: Int) {
        switch index {
        case 3: // Sharing Location
            HMHeartBeat.shared.start()
            TDSwiftAlert.showSingleButtonAlert(title: "Location Sharing", message: "Service Started", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        case 4: // Stop Sharing Location
            HMHeartBeat.shared.stop()
            TDSwiftAlert.showSingleButtonAlert(title: "Location Sharing", message: "Service Terminated", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        default:
            fatalError("TRIP DETAIL POPOVER INDEX INVALID")
        }
    }
}
