import UIKit
import WebKit

class HMResetPasswordViewController: TDSwiftAnimateBackgroundViewController {
    @IBOutlet weak var bgView: TDSwiftRoundedCornerView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBAction func dismissBtnClicked(_ sender: UIButton) { self.dismiss(animated: true, completion: nil) }
    
    let resetPageRequest: URLRequest? = {
        guard let resetPageURL = URL(string: "https://od-havana.com/forget/\(ENV.AUTH.APP_TOKEN)") else { return nil }
        return URLRequest(url: resetPageURL)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegateAndDataSource()
        loadResetPage()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupAppearance()
    }
    
    private func setupDelegateAndDataSource() {
        webView.navigationDelegate = self
    }
    
    private func setupAppearance() {
        // Background view
        bgView.roundedCorners = [.topLeft, .topRight]
    }
    
    private func loadResetPage() {
        if let resetPageRequest = self.resetPageRequest { self.webView.load(resetPageRequest) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add presenting vc reference
        HMViewControllerManager.shared.presentingViewController = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove presenting vc reference
        HMViewControllerManager.shared.presentingViewController = nil
    }
}

extension HMResetPasswordViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
}
