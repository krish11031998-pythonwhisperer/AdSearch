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
    public static func create(id: String, adType: String, location: String?, price: Double?, title: String?) -> Bool {
        let _: SavedAd = CoreDataManager.shared.insertEntity { savedAdInstance in
            savedAdInstance.id = id
            savedAdInstance.adTypeRawValue = adType
            savedAdInstance.location = location
            savedAdInstance.priceRawValue = price as NSNumber?
            savedAdInstance.title = title
        }
        
        return CoreDataManager.shared.save()
    }
    
    
    // MARK: - CoreData: Fetch
    
    public static func fetch(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) -> [SavedAd] {
        return CoreDataManager.shared.fetch(predicate: predicate, sortDescriptors: sortDescriptors) ?? []
    }
    
    
    // MARK: - CoreData: Delete
    
    public static func delete(adId: String) -> Bool {
        let predicate = NSPredicate(format: "id == %@", adId)
        guard let savedAd: SavedAd = CoreDataManager.shared.fetch(predicate: predicate)?.first else {
            print("(DEBUG) no saved ad found with id: \(adId)")
            return false
        }
        
        if CoreDataManager.shared.deleteEntity(savedAd) {
            print("(DEBUG) saved ad deleted successfully")
            return true
        }
        
        return false
    }
}
