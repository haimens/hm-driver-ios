import UIKit

class HMLoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginBtnClicked(_ sender: HMBasicButton) { makeLoginRequest() }
    
    // UIElements
    var spinner: TDSwiftSpinner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup
        setupGestures()
        setupDelegates()
        setupUI()
    }
    
    private func setupGestures() {
        // Tap to end editing
        TDSwiftGesture.addTapToEndEditingGesture(onView: self.view)
    }
    
    private func setupDelegates() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupUI() {
        spinner = TDSwiftSpinner(viewController: self)
    }
    
    private func makeLoginRequest() {
        // Hide keyboard
        self.view.endEditing(true)
        
        // Username and password from textfield
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }
        
        // Show activity indicator
        spinner.show()
        
        // Perform login request
        TDSwiftHavana.shared.login(account: username, password: password) { (result, error) in
            DispatchQueue.main.async {
                // Hide indicator
                self.spinner.hide()
                
                // Handle login result
                if result {
                    // Present main vc
                    self.performSegue(withIdentifier: String(describing: HMMainTabBarController.self), sender: self)
                } else if let error = error {
                    // Handle login error
                    TDSwiftAlert.showSingleButtonAlertWithCancel(title: "Login Failed", message: TDSwiftHavana.getErrorMessage(error: error), actionBtnTitle: "Retry", cancelBtnTitle: "Cancel", presentVC: self, btnAction: { self.makeLoginRequest() })
                }
            }
        }
    }
}

// UITextFieldDelegate
extension HMLoginViewController: UITextFieldDelegate {
    // Keyboard return btn clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == usernameTextField) {
            // Highlight password textfield
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            // Request to login
            makeLoginRequest()
        }
        
        // Do not add line break
        return false
    }
}
