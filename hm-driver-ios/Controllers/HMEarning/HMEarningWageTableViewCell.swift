import UIKit

enum HMEarningWageType {
    case IN
    case OUT
}

class HMEarningWageTableViewCell: UITableViewCell {
    @IBOutlet weak var iconBGView: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    // Static UI values
    static let inIconColor = UIColor(red:0.25, green:0.46, blue:0.02, alpha:1.0)
    static let outIconColor = UIColor(red:0.82, green:0.01, blue:0.11, alpha:1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // Initialize cell appearance
    private func setupUI() {
        iconBGView.clipsToBounds = true
        iconBGView.layer.cornerRadius = iconBGView.frame.width / 2
    }
    
    // Set values of UI elements
    func setValues() {
        self.iconBGView.backgroundColor = HMEarningWageTableViewCell.inIconColor
        self.iconLabel.text = "IN"
        self.dateTimeLabel.text = "June 11 - 11:58 AM"
        self.subtitleLabel.text = "Customer paid cash"
        self.amountLabel.text = "$129.50"
    }
}
