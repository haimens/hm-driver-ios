import UIKit

enum HMEarningWageType {
    case IN
    case OUT
    case UNKNOWN
}

class HMEarningWageTableViewCell: UITableViewCell {
    @IBOutlet weak var iconBGView: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    // Static UI values
    static let inIconColor = UIColor(red:0.18, green:0.81, blue:0.54, alpha:1.0)
    static let outIconColor = UIColor(red:0.96, green:0.21, blue:0.36, alpha:1.0)
    static let unknownIconColor = UIColor.lightGray
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // Initialize cell appearance
    private func setupUI() {
        // Rounded icon
        iconBGView.clipsToBounds = true
        iconBGView.layer.cornerRadius = iconBGView.frame.width / 2
    }
    
    // Set values of UI elements
    func setValues(type: HMEarningWageType, dateTimeString: String, subtitleString: String, amountString: String) {
        switch type {
        case .IN:
            self.iconBGView.backgroundColor = HMEarningWageTableViewCell.inIconColor
            self.iconLabel.text = "IN"
            self.amountLabel.textColor = HMEarningWageTableViewCell.inIconColor
        case .OUT:
            self.iconBGView.backgroundColor = HMEarningWageTableViewCell.outIconColor
            self.iconLabel.text = "OUT"
            self.amountLabel.textColor = HMEarningWageTableViewCell.outIconColor
        case .UNKNOWN:
            self.iconBGView.backgroundColor = HMEarningWageTableViewCell.unknownIconColor
            self.iconLabel.text = "?"
            self.amountLabel.textColor = HMEarningWageTableViewCell.unknownIconColor
        }
        self.dateTimeLabel.text = dateTimeString
        self.subtitleLabel.text = subtitleString
        self.amountLabel.text = amountString
    }
}
