import UIKit

class HMPersonalInfoViewController: UIViewController {
    @IBOutlet weak var profileImageView: TDSwiftSpinnerImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var uploadImageBtn: UIButton!
    
    // UI component
    var spinner: TDSwiftSpinner!
    
    @IBAction func uploadImageBtnClicked(_ sender: UIButton) {
    }
    
    @IBAction func saveChangesBtnClicked(_ sender: HMBasicButton) {
        // Info to modify
        var updatedDriverInfo: [String: Any] = [:]
        if let name = nameTextField.text { updatedDriverInfo["name"] = name }
        if let cell = phoneTextField.text { updatedDriverInfo["cell"] = cell }
        if let email = emailTextField.text { updatedDriverInfo["email"] = email }
        
        // Show spinner
        spinner.show()
        
        // Make modify request
        HMDriver.modifyDriverDetail(body: updatedDriverInfo) { (result, error) in
            DispatchQueue.main.async {
                // Hand request error
                if let error = error {
                    TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: DriverConn.getErrorMessage(error: error), actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                    self.spinner.hide()
                    return
                }
                
                // Driver info updated
                if let _ = result {
                    self.renewAuthAndReloadData()
                }
            }
        }
    }
    
    private func renewAuthAndReloadData() {
        // Retrieve updated auth info
        TDSwiftHavana.shared.renewAuthInfo(completion: { (result, error) in
            DispatchQueue.main.async {
                // Handle login error
                if let error = error {
                    TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Retrieve updated driver info failed: \(TDSwiftHavana.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                }
                
                // Retrieve updated driver info succeed
                if result {
                    self.loadData()
                }
                
                // Hide spinner
                self.spinner.hide()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupGesture()
        loadData()
    }
    
    private func setupUI() {
        // Navigation bar
        configNavigationAppearance()
        
        // Upload image button appearance
        uploadImageBtn.layer.cornerRadius = uploadImageBtn.frame.width / 2
        
        // Profile image appearance
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
        // Spinner
        spinner = TDSwiftSpinner(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add presenting vc reference
        HMViewControllerManager.shared.presentingViewController = self
        
        configNavigationAppearance()
    }
    
    private func configNavigationAppearance() { navigationController?.navigationBar.prefersLargeTitles = false }
    
    private func setupGesture() {
        // Tap to end editing
        TDSwiftGesture.addTapToEndEditingGesture(onView: self.view)
    }
    
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
        
        // ImageView spinner
        profileImageView.showSpinner()
        
        // Profile image
        TDSwiftImageManager.getImage(imageURLString: auth.img_path, imageType: .TDSwiftCacheImage) { (data, error) in
            DispatchQueue.main.async {
                // Hide imageview spinner
                self.profileImageView.hideSpinner()
                
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Load Image Failed", message: TDSwiftRequest.getErrorMessage(error: error, response: nil), actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                if let data = data { self.profileImageView.image = UIImage(data: data) }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove presenting vc reference
        HMViewControllerManager.shared.unlinkPresentingViewController(withViewController: self)
    }
}
