import Foundation

enum TDSwiftImageManagerError: Error {
    case imageURLStringInvalid
}

enum TDSwiftImageType {
    case TDSwiftCacheImage
    case TDSwiftPermanentImage
    case TDSwiftDocumentImage
}

class TDSwiftImageManager {
    static func getImage(imageURLString: String, imageType: TDSwiftImageType, completion: ((Data?, Error?) -> Void)?) {
        // searchPathDir, imagePath
        let searchPathDir: FileManager.SearchPathDirectory
        let imagePath: String?
        switch imageType {
        case .TDSwiftCacheImage:
            searchPathDir = .cachesDirectory
            imagePath = "TDSwiftCachedImages"
        case .TDSwiftPermanentImage:
            searchPathDir = .libraryDirectory
            imagePath = "TDSwiftPermanentImages"
        case .TDSwiftDocumentImage:
            searchPathDir = .documentDirectory
            imagePath = nil
        }
        
        // fileName
        var imageFileName = TDSwiftHash.md5(imageURLString)
        guard let imageFileExtension = URL(string: imageURLString)?.pathExtension else {
            completion?(nil, TDSwiftImageManagerError.imageURLStringInvalid); return
        }
        imageFileName += ".\(imageFileExtension)"
        
        // If image file exists, load image from file dir
        do {
            if (try TDSwiftFileManager.fileExists(dirType: searchPathDir, path: imagePath, fileName: imageFileName)) {
                TDSwiftFileManager.load(dirType: searchPathDir, path: imagePath, fileName: imageFileName) { (data, error) in
                    completion?(data, error)
                }
                return
            }
        } catch {
            completion?(nil, error); return
        }
        
        // Load image
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20
        let urlSession = URLSession(configuration: sessionConfig)
        urlSession.dataTask(with: URL(string: imageURLString)!) { (data, response, error) in
            // If error occurs when loading, handle error
            if (data == nil || error != nil) { completion?(nil, error); return }
            
            // Save image to file system
            TDSwiftFileManager.save(dirType: searchPathDir, data: data!, path: imagePath, fileName: imageFileName, completion: { (result, error) in
                // Handle image error
                if (!result) { completion?(nil, error); return }
                
                // Complete with data
                completion?(data, nil)
            })
            }.resume()
    }
}
