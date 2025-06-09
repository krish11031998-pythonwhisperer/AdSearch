//
//  ImageManager.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 04/06/2025.
//

import Foundation
import UIKit

internal extension NSCache where KeyType == NSString, ObjectType == UIImage {
    
    subscript(url: String) -> UIImage? {
        get {
            object(forKey: url as NSString)
        }
        set {
            if let newValue {
                setObject(newValue, forKey: url as NSString)
            } else {
                removeObject(forKey: url as NSString)
            }
        }
    }
    
}

public actor ImageManager {
    
    private lazy var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        return cache
    }()
    
    private var imageDownloadingTasks: [String: Task<UIImage, Never>] = [:]
    
    private init() {}
    public static let shared: ImageManager = .init()
    public static var adURLBasePath: String = "https://images.finncdn.no/dynamic/480x360c/"
    
    public func fetchImage(urlString: String) async -> UIImage {
        if let image = cache[urlString] {
            return image
        } else if let imageDownloadTask = imageDownloadingTasks[urlString] {
            return await imageDownloadTask.value
        } else {
            let placeHolder: UIImage = .init(systemName: "photo.fill")!
            guard let url = URL(string: urlString) else {
                return placeHolder
            }
            
            let imageDownloadTask: Task<UIImage, Never> = .init {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    imageDownloadingTasks[urlString] = nil
                    if let image = UIImage(data: data) {
                        cache[urlString] = image
                        return image
                    } else {
                        return placeHolder
                    }
                } catch {
                    print("(ERROR) error while fetching image from url[\(urlString)]: \(error.localizedDescription)")
                    return placeHolder
                }
            }
            
            imageDownloadingTasks[urlString] = imageDownloadTask
            return await imageDownloadTask.value
        }
    }
    
}
