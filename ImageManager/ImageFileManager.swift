//
//  ImageFileManager.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 07/06/2025.
//

import UIKit

public actor ImageFileManager {
    
    public static let shared = ImageFileManager()
    
    private let fileManager = FileManager.default
    private var cacheURL: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    @discardableResult
    public func addImage(image: UIImage, name: String) -> Result<URL, Error> {
        guard let imageData = image.jpegData(compressionQuality: 1),
              let fileManagerDocURL = cacheURL
        else { return .failure(NSError(domain: "No Valid File Manager Document URL", code: -1010)) }
        
        let imageDocumentURL = fileManagerDocURL.appendingPathComponent(name + ".cache")
        
        do {
            try imageData.write(to: imageDocumentURL)
            return .success(imageDocumentURL)
        } catch {
            print("(ERROR) while try to add the image: \(error)")
            return .failure(error)
        }
    }
    
    public func retrieveImage(name: String) -> Result<UIImage, Error> {
        guard let fileManagerDocURL = cacheURL else {
            return .failure(NSError(domain: "No Valid File Manager Document URL", code: -1010))
        }
        
        let imageDocumentURL = fileManagerDocURL.appendingPathComponent(name + ".cache")
        
        do {
            let data = try Data(contentsOf: imageDocumentURL)
            guard let image = UIImage(data: data) else {
                return .failure(NSError(domain: "No Valid Image", code: -1012))
            }
            return .success(image)
        } catch {
            return .failure(error)
        }
    }
    
    @discardableResult
    public func removeImage(name: String) -> Result<Bool, Error> {
        guard let fileManagerDocURL = cacheURL else {
            return .failure(NSError(domain: "No Valid File Manager Document URL", code: -1010))
        }
        
        let imageDocumentURL = fileManagerDocURL.appendingPathComponent(name + ".cache")
        
        do {
            try fileManager.removeItem(at: imageDocumentURL)
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
}
