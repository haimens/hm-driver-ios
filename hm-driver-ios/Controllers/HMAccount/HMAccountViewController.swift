import UIKit

class HMAccountViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        // Navigation appearance
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect tableview cell
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 5: // Logout
            // Remove current auth and user info
            TDSwiftHavana.shared.removeAuthInfo()
            TDSwiftHavana.shared.removeUserInfo()
            
            // Present auth vc
            let authVC = self.storyboard!.instantiateViewController(withIdentifier: String(describing: HMAuthViewController.self))
            self.present(authVC, animated: true, completion: nil)
        default:
            fatalError("ACCOUNT VC TABLEVIEW INDEX INVALID")
        }
    }
}
