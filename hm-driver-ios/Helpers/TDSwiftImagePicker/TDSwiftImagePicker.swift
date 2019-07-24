import Foundation
import UIKit

public protocol TDSwiftImagePickerDelegate: class {
    func didSelect(mediaInfo: [UIImagePickerController.InfoKey : Any])
    func didCancel()
}

public enum TDSwiftImagePickerMediaType: String {
    case publicImage = "public.image"
    case publicMovie = "public.movie"
}

public enum TDSwiftImageQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

public class TDSwiftImagePicker: NSObject {
    // Picker and presentVC
    private let pickerVC: UIImagePickerController
    private weak var presentVC: UIViewController?
    
    // Delegate instance
    public weak var delegate: TDSwiftImagePickerDelegate?
    
    public init(presentOn presentVC: UIViewController, rectCropping: Bool, mediaTypes: [TDSwiftImagePickerMediaType]) {
        // Init properties
        self.pickerVC = UIImagePickerController()
        self.presentVC = presentVC
        
        // Init super class
        super.init()
        
        // Picker properties
        self.pickerVC.delegate = self
        self.pickerVC.allowsEditing = rectCropping
        var mediaTypeString: [String] = []
        mediaTypes.forEach { mediaTypeString.append($0.rawValue) }
        self.pickerVC.mediaTypes = mediaTypeString
    }
    
    public func present() {
        // Action sheet instance
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Actions if available
        if let action = self.action(for: .camera, title: "Take photo") { actionSheet.addAction(action) }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") { actionSheet.addAction(action) }
        if let action = self.action(for: .photoLibrary, title: "Photo library") { actionSheet.addAction(action) }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present action sheet
        self.presentVC?.present(actionSheet, animated: true, completion: nil)
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        // Verify source type availability
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return nil }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerVC.sourceType = type
            self.presentVC?.present(self.pickerVC, animated: true)
        }
    }
    
    public static func convert(image: UIImage, toQuality quality: TDSwiftImageQuality) -> Data? {
        return image.jpegData(compressionQuality: quality.rawValue)
    }
}

extension TDSwiftImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss picker vc
        picker.dismiss(animated: true, completion: nil)
        
        // Delegate method
        self.delegate?.didCancel()
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Dismiss picker vc
        picker.dismiss(animated: true, completion: nil)
        
        // Delegate method
        self.delegate?.didSelect(mediaInfo: info)
    }
}
