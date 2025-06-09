//
//  SavedAd.swift
//  Model
//
//  Created by Krishna Venkatramani on 05/06/2025.
//

import Foundation
import UIKit
import CoreData

@objc(SavedAd)
public class SavedAd: NSManagedObject {
    
    @NSManaged public var id: String
    @NSManaged internal var adTypeRawValue: String
    @NSManaged private(set) public var imageString: String?
    @NSManaged private(set) public var location: String?
    @NSManaged internal var priceRawValue: NSNumber?
    @NSManaged private(set) public var title: String?
    
    public var adType: AdType {
        .init(rawValue: adTypeRawValue)!
    }
    
    public var price: Double? {
        return priceRawValue as? Double
    }
    
    
    // MARK: - CoreData: Create
    
    @discardableResult
    public static func create(id: String, adType: String, location: String?, price: Double?, title: String?, imageString: String?) -> Bool {
        let savedAdInstance: SavedAd = CoreDataManager.shared.insertEntity { savedAdInstance in
            savedAdInstance.id = id
            savedAdInstance.adTypeRawValue = adType
            savedAdInstance.imageString = imageString
            savedAdInstance.location = location
            savedAdInstance.priceRawValue = price as NSNumber?
            savedAdInstance.title = title
        }
        
        return CoreDataManager.shared.save()
    }
    
    
    // MARK: - CoreData: Fetch
    
    public static func fetch(in context: NSManagedObjectContext) -> [SavedAd] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedAd")
        var savedAds: [SavedAd] = []
        do {
            if let fetchSavedAds = try context.fetch(fetchRequest) as? [SavedAd] {
                savedAds = fetchSavedAds
            }
        } catch {
            print("(DEBUG) Failed While Fetching: ", error.localizedDescription)
        }
        return savedAds
    }
    
}
