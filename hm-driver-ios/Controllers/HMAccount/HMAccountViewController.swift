import UIKit

class HMAccountViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigationAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configNavigationAppearance()
    }
    
    private func configNavigationAppearance() { navigationController?.navigationBar.prefersLargeTitles = true }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect tableview cell
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 3: // Sharing Location
            HMHeartBeat.shared.start()
            TDSwiftAlert.showSingleButtonAlert(title: "Location Sharing", message: "Service Started", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        case 4: // Stop Sharing Location
            HMHeartBeat.shared.stop()
            TDSwiftAlert.showSingleButtonAlert(title: "Location Sharing", message: "Service Terminated", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
        case 5: // Logout
            // Remove current auth and user info
            TDSwiftHavana.shared.removeAuthInfo()
            TDSwiftHavana.shared.removeUserInfo()
            
            // Present auth vc
            let authVC = self.storyboard!.instantiateViewController(withIdentifier: String(describing: HMAuthViewController.self))
            self.present(authVC, animated: true, completion: nil)
        default:
            performSegue(withIdentifier: String(describing: HMPersonalInfoViewController.self), sender: self)
        }
    }
}
