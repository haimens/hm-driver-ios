import UIKit
import MessageKit

struct HMCustomerMessagingMember {
    let id: Int
    let name: String
    let imagePath: String
    
    static func getNameWithType(type: Int) -> String? {
        switch type {
        case 1:
            return "Admin"
        case 2:
            return "Driver"
        case 3:
            return "System"
        case 4:
            return "Customer"
        default:
            return nil
        }
    }
}

struct HMCustomerMessagingMessage: MessageType {
    var sender: SenderType {
        return Sender(id: "\(member.id)", displayName: member.name)
    }
    var kind: MessageKind {
        return .text(text)
    }
    var sentDate: Date
    let messageId: String
    let member: HMCustomerMessagingMember
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
        member = HMCustomerMessagingMember(id: 2, name: HMCustomerMessagingMember.getNameWithType(type: 2) ?? CONST.UI.NOT_AVAILABLE_PLACEHOLDER    , imagePath: TDSwiftHavana.shared.auth?.img_path ?? "")
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
                let name = HMCustomerMessagingMember.getNameWithType(type: type),
                let imagePath = record["img_path"] as? String {
                messages.append(.init(sentDate: date, messageId: smsToken, member: .init(id: type, name: name, imagePath: imagePath), text: message))
            }
        }
        
        // Reload collection view
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
}

extension HMCustomerMessagingViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return Sender(id: "\(member.id)", displayName: member.name)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
