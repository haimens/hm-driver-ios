import UIKit

class HMPersonalInfoViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configNavigationAppearance()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configNavigationAppearance()
    }
    
    private func configNavigationAppearance() { navigationController?.navigationBar.prefersLargeTitles = false }
    
    private func loadData() {
        // App auth instance
        guard let auth = TDSwiftHavana.shared.auth else {
            TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Driver info not found", actionBtnTitle: "OK", presentVC: self) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        // Display current driver info
        nameTextField.text = auth.name
        phoneTextField.text = auth.cell
        emailTextField.text = auth.email
    }
}
