import Foundation

enum TDSwiftFileManagerError: Error {
    case fileDoesNotExist
    case unknown
}

class TDSwiftFileManager {
    static func save(dirType: FileManager.SearchPathDirectory, data: Data, path: String?, fileName: String, completion: ((Bool, Error?) -> Void)?) {
        do {
            // URL
            var dirURL = try FileManager.default.url(for: dirType, in: .userDomainMask, appropriateFor: nil, create: true)
            if let path = path { dirURL = dirURL.appendingPathComponent(path) }
            let fileURL = dirURL.appendingPathComponent(fileName)
            
            // If dir do not exist, create dir
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            
            // Save file to url async
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try data.write(to: fileURL, options: .atomic)
                    
                    // Confirm file exists
                    if (FileManager.default.fileExists(atPath: fileURL.path)) {
                        completion?(true, nil)
                    } else {
                        completion?(false, TDSwiftFileManagerError.unknown)
                    }
                } catch {
                    completion?(false, error)
                }
            }
        } catch {
            completion?(false, error)
        }
    }
    
    static func load(dirType: FileManager.SearchPathDirectory, path: String?, fileName: String, completion: ((Data?, Error?) -> Void)?) {
        do {
            // Check file existence
            if (try !fileExists(dirType: dirType, path: path, fileName: fileName)) {
                completion?(nil, TDSwiftFileManagerError.fileDoesNotExist); return
            }
            
            // URL
            var dirURL = try FileManager.default.url(for: dirType, in: .userDomainMask, appropriateFor: nil, create: true)
            if let path = path { dirURL = dirURL.appendingPathComponent(path) }
            let fileURL = dirURL.appendingPathComponent(fileName)
            
            // Result
            let data = try Data(contentsOf: fileURL)
            completion?(data, nil)
        } catch {
            completion?(nil, error)
        }
    }
    
    static func fileExists(dirType: FileManager.SearchPathDirectory, path: String?, fileName: String) throws -> Bool {
        do {
            // URL
            var dirURL = try FileManager.default.url(for: dirType, in: .userDomainMask, appropriateFor: nil, create: true)
            if let path = path { dirURL = dirURL.appendingPathComponent(path) }
            let fileURL = dirURL.appendingPathComponent(fileName)
            
            return FileManager.default.fileExists(atPath: fileURL.path)
        } catch {
            throw error
        }
    }
    
    static func delete(dirType: FileManager.SearchPathDirectory, path: String?, fileName: String, completion: ((Bool, Error?) -> Void)?) {
        do {
            // Check file existence
            if (try !fileExists(dirType: dirType, path: path, fileName: fileName)) {
                completion?(false, TDSwiftFileManagerError.fileDoesNotExist); return
            }
            
            // URL
            var dirURL = try FileManager.default.url(for: dirType, in: .userDomainMask, appropriateFor: nil, create: true)
            if let path = path { dirURL = dirURL.appendingPathComponent(path) }
            let fileURL = dirURL.appendingPathComponent(fileName)
            
            // Delete file async
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    completion?(true, nil); return
                } catch {
                    completion?(false, error); return
                }
            }
        } catch {
            completion?(false, error)
        }
    }
}
