import UIKit

class HMEarningSalaryTableViewCell: UITableViewCell {
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func setValues(dateTimeString: String, subtitleString: String, amountString: String) {
        self.dateTimeLabel.text = dateTimeString
        self.subtitleLabel.text = subtitleString
        self.amountLabel.text = amountString
    }
}
