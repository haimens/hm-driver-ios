import UIKit

enum TDSwiftInfiniteTableViewState {
    case loading
    case standBy
}

class TDSwiftInfiniteTableView: UITableView {
    var rowsToLoadNextPage: Int = 3
    
    @IBInspectable var footerSpinnerColor: UIColor = .darkGray {
        didSet {
            if let spinner = self.tableFooterView as? UIActivityIndicatorView {
                spinner.color = footerSpinnerColor
            }
        }
    }
    
    @IBInspectable var isLoadingNewContent: Bool = true {
        didSet {
            if let spinner = self.tableFooterView as? UIActivityIndicatorView {
                isLoadingNewContent ? spinner.startAnimating() : spinner.stopAnimating()
            }
        }
    }
    
    var footerSpinnerStyle: UIActivityIndicatorView.Style = .whiteLarge {
        didSet {
            if let spinner = self.tableFooterView as? UIActivityIndicatorView {
                spinner.style = footerSpinnerStyle
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFooterSpinner()
    }
    
    private func initFooterSpinner() {
        let spinner = UIActivityIndicatorView(style: footerSpinnerStyle)
        spinner.color = footerSpinnerColor
        spinner.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 44)
        self.tableFooterView = spinner
    }
}
