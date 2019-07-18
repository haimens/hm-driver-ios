import UIKit
import MessageKit

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
    
    // Conversation data
    var messages: [HMCustomerMessagingMessage]!
    var member: HMCustomerMessagingMember!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configConversationData()
        configMessageUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Validate customer token
        if customerToken == nil {
            TDSwiftAlert.showSingleButtonAlert(title: "Load Conversation Failed", message: "Customer info missing", actionBtnTitle: "Dismiss", presentVC: self) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        // Conversation data
        loadData()
    }
    
    private func configConversationData() {
        messages = []
        member = HMCustomerMessagingMember(senderId: "2", imagePath: TDSwiftHavana.shared.auth?.img_path ?? "")
    }
    
    private func configMessageUI() {
        self.messagesCollectionView.messagesDataSource = self
        self.messagesCollectionView.messagesLayoutDelegate = self
        self.messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension HMCustomerMessagingViewController: TDSwiftData {
    func loadData() {
        HMSms.getAllSMS(withCustomerToken: self.customerToken, query: nil) { (result, error) in
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
        guard let recordList = data["record_list"] as? [[String : Any]] else {
            TDSwiftAlert.showSingleButtonAlert(title: "Request Failed", message: "Conversation records invalid", actionBtnTitle: "OK", presentVC: self, btnAction: nil)
            return
        }
        
        // Parse each record
        recordList.forEach { (record) in
            if let smsToken = record["sms_token"] as? String,
                let dateString = record["udate"] as? String,
                let date = TDSwiftDate.utcTimeStringToDate(timeString: dateString, withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"),
                let message = record["message"] as? String,
                let type = record["type"] as? Int,
                let imagePath = record["img_path"] as? String {
                messages.append(.init(sender: HMCustomerMessagingMember(senderId: "\(type)", imagePath: imagePath), sentDate: date, messageId: smsToken, text: message))
            }
        }
        
        // Reload collection view
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
}

extension HMCustomerMessagingViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return member
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
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
}
