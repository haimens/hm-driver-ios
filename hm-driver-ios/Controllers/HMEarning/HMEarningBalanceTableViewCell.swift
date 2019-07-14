import UIKit

class HMEarningBalanceTableViewCell: UITableViewCell {
    @IBOutlet weak var balanceLabel: UILabel!
    
    func setBalance(balanceString: String) {
        self.balanceLabel.text = balanceString
    }
}
