import UIKit

class HMTripDetailViewController: UIViewController {
    // Popover menu
    var popover: TDSwiftPopover!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        popover.dismiss()
    }
    
    private func setupUI() {
        // Navigation appearance
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Menu bar button
        let menuBarButtonItem = UIBarButtonItem(title: "● ● ● ", style: .plain, target: self, action: #selector(self.showOptionsMenu(_:)))
        menuBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 7.0)], for: .normal)
        menuBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 7.0)], for: .selected)
        navigationItem.rightBarButtonItem = menuBarButtonItem
        
        // Popover menu
        let popoverItems = [
            TDSwiftPopoverItem(iconImage: #imageLiteral(resourceName: "conversation"), titleText: "Text Customer"),
            TDSwiftPopoverItem(iconImage: #imageLiteral(resourceName: "phone"), titleText: "Call Customer"),
            TDSwiftPopoverItem(iconImage: #imageLiteral(resourceName: "phone"), titleText: "Call Dispatch Center"),
            TDSwiftPopoverItem(iconImage: #imageLiteral(resourceName: "placeholder"), titleText: "Sharing Location"),
            TDSwiftPopoverItem(iconImage: #imageLiteral(resourceName: "stop"), titleText: "Stop Sharing Location")
        ]
        
        // Popover instance
        popover = TDSwiftPopover.init(config: TDSwiftPopoverConfig(backgroundColor: UIColor(red:0.06, green:0.03, blue:0.42, alpha:1.0),
                                                                   size: CGSize(width: 195.0, height: 222.0),
                                                                   items: popoverItems,
                                                                   itemTitleColor: .white,
                                                                   itemTitleFont: UIFont.systemFont(ofSize: 12.0, weight: .medium)))
        popover.delegate = self
    }
    
    @objc private func showOptionsMenu(_ sender: UIBarButtonItem) {
        let buttonItemView = self.navigationItem.rightBarButtonItem!.value(forKey: "view") as! UIView
        let buttonItemViewCenter = buttonItemView.convert(buttonItemView.center, to: self.view)
        let popoverOrigin = CGPoint(x: buttonItemViewCenter.x - 5, y: buttonItemViewCenter.y + 10)
        
        popover.present(onView: self.navigationController!.view, atPoint: popoverOrigin)
    }
}

extension HMTripDetailViewController: TDSwiftPopoverDelegate {
    func didSelect(item: TDSwiftPopoverItem, atIndex index: Int) {
        print("index \(index)")
    }
}
