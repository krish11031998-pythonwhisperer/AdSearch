//
//  ImageFileManager.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 07/06/2025.
//

import UIKit

public actor ImageFileManager {
    
    public static let shared = ImageFileManager()
    
    public func addImage(image: UIImage, name: String) -> Result<URL, Error> {
        guard let imageData = image.jpegData(compressionQuality: 1),
              let fileManagerDocURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return .failure(NSError(domain: "No Valid File Manager Document URL", code: -1010)) }
        
        let imageDocumentURL = fileManagerDocURL.appendingPathComponent(name)
        print("imageDocumentURL: \(imageDocumentURL.absoluteString)")
        do {
            try imageData.write(to: imageDocumentURL)
            return .success(imageDocumentURL)
        } catch {
            print("(ERROR) while try to add the image: \(error)")
            return .failure(error)
        }
    }
    
    public func retrieveImage(localImagePath: String) -> Result<UIImage, Error> {
        let fileManager = FileManager.default

        let imagePathURL = URL(filePath: localImagePath)
        
        guard fileManager.fileExists(atPath: localImagePath)
        else {
            return .failure(NSError(domain: "File doesn't exist", code: -1011))
        }
        
        do {
            let data = try Data(contentsOf: imagePathURL)
            guard let image = UIImage(data: data) else {
                return .failure(NSError(domain: "No Valid Image", code: -1012))
            }
            return .success(image)
        } catch {
            print("(ERROR) while reading image for URL: \(imagePathURL) - \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
}
