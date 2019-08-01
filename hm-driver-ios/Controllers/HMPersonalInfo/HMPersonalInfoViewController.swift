import UIKit

class HMPersonalInfoViewController: UIViewController {
    @IBOutlet weak var profileImageView: TDSwiftSpinnerImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var uploadImageBtn: UIButton!
    
    // UI component
    var spinner: TDSwiftSpinner!
    var imagePicker: TDSwiftImagePicker!
    
    @IBAction func uploadImageBtnClicked(_ sender: UIButton) {
        profileImageView.showSpinner()
        imagePicker.present()
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
                
                // Renew info succeed, prompt success and dismiss vc
                if result {
                    if let presentingViewController = HMViewControllerManager.shared.presentingViewController {
                        TDSwiftAlert.showSingleButtonAlert(title: "Success", message: "Changes saved", actionBtnTitle: "OK", presentVC: presentingViewController, btnAction: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
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
        
        // Init picker
        self.imagePicker = TDSwiftImagePicker(presentOn: self, rectCropping: true, mediaTypes: [.publicImage, .publicMovie])
        self.imagePicker.delegate = self
        
        // Upload image button appearance
        uploadImageBtn.layer.cornerRadius = uploadImageBtn.frame.width / 2
        uploadImageBtn.isHidden = true
        
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
                
                // Show upload image button
                self.uploadImageBtn.isHidden = false
                
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

extension HMPersonalInfoViewController: TDSwiftImagePickerDelegate {
    func didSelect(mediaInfo: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = mediaInfo[.editedImage] as? UIImage {
            // Upload image
            TDSwiftHavanaImageUploader.shared.upload(image: editedImage, imageType: .avatar) { (response, error) in
                DispatchQueue.main.async {
                    // Parse result
                    let result = TDSwiftHavanaImageUploader.handleResponse(responseData: response, error: error)
                    
                    // Handle upload error
                    if let errorMessage = result.errorMessage {
                        TDSwiftAlert.showSingleButtonAlert(title: "Upload Failed", message: errorMessage, actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                    }
                    
                    // Patch driver detail
                    if let imagePath = result.imagePath {
                        // Show spinner
                        self.profileImageView.showSpinner()

                        HMDriver.modifyDriverDetail(body: ["img_path": imagePath], completion: { (response, error) in
                            DispatchQueue.main.async {
                                // Hide spinner
                                self.profileImageView.hideSpinner()
                                
                                // Hand request error
                                if let error = error {
                                    TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: DriverConn.getErrorMessage(error: error), actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                                    self.profileImageView.hideSpinner()
                                    return
                                }
                                
                                // Driver info updated
                                if let _ = response {
                                    self.spinner.show()
                                    self.renewAuthAndReloadData()
                                }
                            }
                        })
                    }
                    
                    // Hide spinner
                    self.profileImageView.hideSpinner()
                }
            }
        }
    }
    
    func didCancel() {
        profileImageView.hideSpinner()
    }
}
