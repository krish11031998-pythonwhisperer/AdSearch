//
//  CoreDataManager.swift
//  Model
//
//  Created by Krishna Venkatramani on 05/06/2025.
//

import Foundation
import CoreData
import Combine

public class CoreDataManager {
    
    private var persistentContainer: NSPersistentContainer!
    public static let shared = CoreDataManager()
    
    private init() {
        setupPersistantContainer()
    }
    
    private func setupPersistantContainer() {
        guard let bundle = Bundle(identifier: "com.Krishna.Model") else {
            fatalError("Can't find the bundle")
        }
        
        guard let modelURL = bundle.url(forResource: "AdSearch", withExtension: "momd") else {
            fatalError("Can't find the model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Can't load the model")
        }
        
        let persistentContainer = NSPersistentContainer(name: "AdSearch", managedObjectModel: managedObjectModel)
        
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError(error.localizedDescription)
            }
            
            self.persistentContainer = persistentContainer
        }
    }
    
    
    // MARK: - Exposed Methods
    
    @discardableResult
    public func save() -> Bool {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
                return true
            } catch {
                print("(ERROR) error while saving to the context: ", error.localizedDescription)
                return false
            }
        }
        
        return false
    }
    
    public func fetch<T: NSManagedObject>(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) -> [T]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(NSStringFromClass(T.self)))
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        return try? persistentContainer?.viewContext.fetch(fetchRequest) as? [T]
    }
    
    public func insertEntity<T: NSManagedObject>(_ transform: ((T) -> Void)? = nil) -> T {
        let entityName = String(NSStringFromClass(T.self))
        let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: persistentContainer.viewContext) as! T
        transform?(object)
        return object
    }
    
    @discardableResult
    public func deleteEntity<T: NSManagedObject>(_ entityInstance: T) -> Bool {
        persistentContainer.viewContext.delete(entityInstance)
        return save()
    }
    
    public var changeInContextPublisher: AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
