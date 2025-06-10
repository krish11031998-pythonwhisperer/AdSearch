//
//  RemoteImageManager.swift
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

public actor RemoteImageManager {
    
    private lazy var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        return cache
    }()
    
    private var imageDownloadingTasks: [String: Task<UIImage, Error>] = [:]
    
    private init() {}
    public static let shared: RemoteImageManager = .init()
    public static var adURLBasePath: String = "https://images.finncdn.no/dynamic/480x360c/"
    
    public func fetchImage(urlString: String) async -> Result<UIImage, Error> {
        if let image = cache[urlString] {
            return .success(image)
        } else if let imageDownloadTask = imageDownloadingTasks[urlString] {
            do {
                let image = try await imageDownloadTask.value
                return .success(image)
            } catch {
                return .failure(error)
            }
        } else {
            guard let url = URL(string: urlString) else {
                return .failure(URLError.badURL as! Error)
            }
            
            let imageDownloadTask: Task<UIImage, Error> = .init {
                do {
                    try Task.checkCancellation()
                    
                    let (data, _) = try await URLSession.shared.data(from: url)
                    
                    try Task.checkCancellation()
                    
                    if let image = UIImage(data: data) {
                        cache[urlString] = image
                        return image
                    } else {
                        throw NSError(domain: "Could not decode image", code: 1015)
                    }
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    throw error
                }
            }
            
            imageDownloadingTasks[urlString] = imageDownloadTask
            do {
                let image = try await imageDownloadTask.value
                return .success(image)
            } catch {
                return .failure(error)
            }
        }
    }
    
    public func fetchImageWithoutRequest(urlString: String) async -> Result<UIImage, Error> {
        if let image = cache[urlString] {
            return .success(image)
        } else if let imageDownloadTask = imageDownloadingTasks[urlString] {
            return await imageDownloadTask.result
        } else {
            return .failure(NSError(domain: "No image found", code: 1016))
        }
    }
    
}
