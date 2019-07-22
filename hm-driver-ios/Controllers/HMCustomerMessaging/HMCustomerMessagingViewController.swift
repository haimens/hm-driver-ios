import UIKit
import MessageKit
import InputBarAccessoryView

struct HMCustomerMessagingMember: SenderType {
    var senderId: String
    var imagePath: String
    var displayName: String {
        return HMCustomerMessagingMember.getNameWithId(id: senderId)
    }
    var tintColor: UIColor {
        return HMCustomerMessagingMember.getTintWithId(id: senderId)
    }
    
    static func getNameWithId(id: String) -> String {
        switch id {
        case "1":
            return "Admin"
        case "2":
            return "Driver"
        case "3":
            return "System"
        case "4":
            return "Customer"
        default:
            return "-"
        }
    }
    
    static func getTintWithId(id: String) -> UIColor {
        switch id {
        case "1":
            return UIColor(red:0.37, green:0.45, blue:0.89, alpha:1.0)
        case "2":
            return UIColor(red:0.18, green:0.81, blue:0.54, alpha:1.0)
        case "3":
            return UIColor(red:0.10, green:0.11, blue:0.30, alpha:1.0)
        case "4":
            return UIColor(red:0.90, green:0.91, blue:0.93, alpha:1.0)
        default:
            return UIColor.lightGray
        }
    }
    
}

struct HMCustomerMessagingMessage: MessageType {
    var sender: SenderType
    var kind: MessageKind {
        return .text(text)
    }
    var sentDate: Date
    let messageId: String
    let text: String
}

class HMCustomerMessagingViewController: MessagesViewController {
    var customerToken: String!
    var tripToken: String!
    
    // UI elements
    var spinner: TDSwiftSpinner!
    var refreshControl: UIRefreshControl!
    
    // Conversation data
    var messages: [HMCustomerMessagingMessage]!
    var messagesEnd: Int!
    var messagesCount: Int!
    var member: HMCustomerMessagingMember!
    
    @IBAction func dismissBtnClicked(_ sender: UIButton) { self.dismiss(animated: true, completion: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        configConversationData()
        configMessageUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add presenting vc reference
        HMViewControllerManager.shared.presentingViewController = self
        
        // Validate customer token
        if customerToken == nil {
            TDSwiftAlert.showSingleButtonAlert(title: "Load Conversation Failed", message: "Customer info missing", actionBtnTitle: "Dismiss", presentVC: self) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        // Conversation data
        loadData()
    }
    
    private func configUI() {
        // Spinner
        spinner = TDSwiftSpinner(viewController: self)
        
        // refreshControl
        refreshControl =  UIRefreshControl()
        self.messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    private func configConversationData() {
        member = HMCustomerMessagingMember(senderId: "2", imagePath: TDSwiftHavana.shared.auth?.img_path ?? "")
    }
    
    private func configMessageUI() {
        self.messagesCollectionView.messagesDataSource = self
        self.messagesCollectionView.messagesLayoutDelegate = self
        self.messagesCollectionView.messagesDisplayDelegate = self
        self.messageInputBar.delegate = self
        
        self.messageInputBar.tintColor = CONST.UI.THEME_COLOR
        self.messageInputBar.sendButton.setTitleColor(CONST.UI.THEME_COLOR, for: .normal)
        self.scrollsToBottomOnKeyboardBeginsEditing = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove presenting vc reference
        HMViewControllerManager.shared.unlinkPresentingViewController(withViewController: self)    }
}

extension HMCustomerMessagingViewController: TDSwiftData {
    func loadData() {
        // Data list reached end, return
        if let messagesCount = messagesCount, let messagesEnd = messagesEnd {
            if messagesCount <= messagesEnd {
                self.refreshControl.endRefreshing()
                return
            }
        }
        
        // Show spinner
        spinner.show()
        
        // All message request
        HMSms.getAllSMS(withCustomerToken: self.customerToken, query: ["order_key": "udate", "order_direction": "DESC", "start": messagesEnd ?? 0]) { (result, error) in
            DispatchQueue.main.async {
                // Hand request error
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: DriverConn.getErrorMessage(error: error), actionBtnTitle: "OK", presentVC: self, btnAction: nil) }
                
                // Parse request response
                if let result = result { self.parseData(data: result) }
            }
        }
    }
    
    func parseData(data: [String : Any]) {
        // Record list
        guard let recordList = data["record_list"] as? [[String : Any]],
            let end = data["end"] as? Int,
            let count = data["count"] as? Int
            else {
                TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Conversation records invalid", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
                return
        }
        
        // Update list info
        self.messagesEnd = end
        self.messagesCount = count
        
        // Parse each record
        if messages == nil { messages = [] }
        recordList.forEach { (record) in
            // Parse img path
            var imgPath = ""
            if let type = record["type"] as? Int {
                if type == 1 {
                    imgPath = record["lord_img_path"] as? String ?? ""
                } else if type == 2 {
                    imgPath = record["driver_img_path"] as? String ?? ""
                } else if type == 3 {
                    imgPath = TDSwiftHavana.shared.auth?.icon_path ?? ""
                } else if type == 4 {
                    imgPath = record["img_path"] as? String ?? ""
                }
            }
            
            // Parse othe info
            if let type = record["type"] as? Int,
                let smsToken = record["sms_token"] as? String,
                let dateString = record["udate"] as? String,
                let date = TDSwiftDate.utcTimeStringToDate(timeString: dateString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"),
                let message = record["message"] as? String {
                messages.insert(.init(sender: HMCustomerMessagingMember(senderId: "\(type)", imagePath: imgPath), sentDate: date, messageId: smsToken, text: message), at: 0)
            }
        }
        
        // Reload collection view
        self.messagesCollectionView.reloadDataAndKeepOffset()
        
        // Scroll to bottom if loading first page
        if !self.refreshControl.isRefreshing {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
        
        // Hide spinner, end refresh control
        spinner.hide()
        self.refreshControl.endRefreshing()
    }
    
    func purgeData() {
        messagesEnd = nil
        messagesCount = nil    }
}

extension HMCustomerMessagingViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return member
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {        
        return messages == nil ? 0 : messages.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Reset avatar view image
        avatarView.image = nil
        
        // HMCustomerMessagingMember
        let member = message.sender as! HMCustomerMessagingMember
        
        // Avatar view bg and image
        avatarView.backgroundColor = member.tintColor
        TDSwiftImageManager.getImage(imageURLString: member.imagePath, imageType: .TDSwiftCacheImage, completion: { (data, error) in
            DispatchQueue.main.async {
                if let data = data { avatarView.image = UIImage(data: data) }
            }
        })
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        // Member instance
        let message = message as! HMCustomerMessagingMessage
        let member = message.sender as! HMCustomerMessagingMember
        
        // Bubble style according to member type
        if member.senderId == self.member.senderId {
            return .bubbleTail(.bottomRight, .pointedEdge)
        } else {
            return .bubbleTail(.bottomLeft, .pointedEdge)
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // Member instance
        let message = message as! HMCustomerMessagingMessage
        let member = message.sender as! HMCustomerMessagingMember
        
        // Member tint color
        return member.tintColor
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // Member instance
        let message = message as! HMCustomerMessagingMessage
        let member = message.sender as! HMCustomerMessagingMember
        
        // Bubble text color according to member type
        if member.senderId == "4" {
            return .gray
        } else {
            return .white
        }
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Member instance
        let message = message as! HMCustomerMessagingMessage
        let member = message.sender as! HMCustomerMessagingMember
        
        // No label for current mamber
        if member.senderId == self.member.senderId { return nil }
        
        // Member display name
        return NSAttributedString(
            string: member.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.gray])
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        // Member instance
        let message = message as! HMCustomerMessagingMessage
        let member = message.sender as! HMCustomerMessagingMember
        
        // No label height for current mamber
        if member.senderId == self.member.senderId {
            return 0.0
        } else {
            return 12.0
        }
    }
}

extension HMCustomerMessagingViewController: MessageInputBarDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Show spinner
        spinner.show()
        
        // Send SMS
        HMSms.sendSMS(withCustomerToken: customerToken, body: ["title": "From Driver - \(TDSwiftHavana.shared.auth?.name ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER)", "message": text]) { (result, error) in
            DispatchQueue.main.async {
                // Clear input
                inputBar.inputTextView.text = ""
                
                // Hide spinner
                self.spinner.show()
                
                // Handle error
                if let error = error { TDSwiftAlert.showSingleButtonAlert(title: "Send SMS Failed", message: "\(DriverConn.getErrorMessage(error: error))", actionBtnTitle: "OK", presentVC: self, btnAction: nil); return }
                
                // Reload messaging view
                self.purgeData()
                self.loadData()
            }
        }
    }
}
