//
//  CDManager.swift
//  CDManager
//
//  Created by Wendy Liga on 15/09/19.
//  Copyright © 2019 Wendy Liga. All rights reserved.
//

import CoreData

public class CDManager<T: NSManagedObject> {
    /// Persistent container of core data
    private let container: NSManagedObjectContext

    /// Init of Core Data Manager class
    ///
    /// - Parameter container: Persistent core data container
    public init(container: NSManagedObjectContext) {
        self.container = container
    }

    /// Get Entity Name
    ///
    /// - Returns: String fo class name
    private func getEntityName() -> String {
        return NSStringFromClass(T.self)
    }

    /// Generate NSManagedObject based on NSManagedObjectID
    ///
    /// - Parameter id: NSManagedObjectID of target
    /// - Returns: Generic of NSManagedObject
    public func getObject(by id: NSManagedObjectID?) -> T? {
        guard let id = id else {
            return nil
        }

        return container.object(with: id) as? T
    }

    /// Create generic NSManagedObject
    ///
    /// - Returns: Generic NSManagedObject
    public func createObject() -> T? {
        guard let entity = NSEntityDescription.entity(forEntityName: self.getEntityName(), in: container)
        else { return nil }

        return T(entity: entity, insertInto: container)
    }

    /// Delete NSManagedObject from container
    ///
    /// - Parameter object: Generic NSManagedObject
    /// - Returns: Status of operation
    public func delete(object: NSManagedObject) -> Bool {
        container.delete(object)
        return saveChanges()
    }

    /// Function to delete all data
    ///
    /// - Returns: Status of Operation
    public func clearAll() -> Bool {
        return deleteBatch()
    }

    /// Delete all data of current T based on NSFetchRequest
    ///
    /// - Returns: Status of operation
    public func deleteBatch(forRequest request: NSFetchRequest<NSFetchRequestResult>? = nil) -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>!

        // determine default request
        if let request = request {
            fetchRequest = request
        } else {
            fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: getEntityName())
        }

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try container.execute(deleteRequest)
            return saveChanges()
        } catch {
            return false
        }
    }

    /// Delete all data of current T based on NSManagedObjectID
    ///
    /// - Returns: Status of operation
    public func deleteBatch(forObjects objects: [NSManagedObject]) -> Bool {
        let objectIDs = objects.map { object -> NSManagedObjectID in
            object.objectID
        }

        let deleteRequest = NSBatchDeleteRequest(objectIDs: objectIDs)

        do {
            try container.execute(deleteRequest)
            return saveChanges()
        } catch {
            return false
        }
    }

    /// Insert NSManagedObject to container
    ///
    /// - Parameter object: Generic NSManagedObject
    /// - Returns: Status of operation
    public func insert(object: NSManagedObject) -> Bool {
        container.insert(object)
        return saveChanges()
    }

    /// Update NSManagedObject to container
    ///
    /// - Parameter object: Generic NSManagedObject
    /// - Returns: Status of operation
    public func update() -> Bool {
        return saveChanges()
    }

    /// Save changes on current container
    ///
    /// - Returns: Status of operation
    public func saveChanges() -> Bool {
        do {
            try container.save()
            return true
        } catch {
            return false
        }
    }

    /// Fetch generic NSManagedObject with custom sort and predicate
    ///
    /// - Parameters:
    ///   - sort: Custom sort with nil default
    ///   - predicate: Custom predicate with nil default
    /// - Returns: Optional Array of T which will depend on result of fetch
    public func fetch(withSort sort: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil) -> [T]? {
        let request = T.fetchRequest()
        request.sortDescriptors = sort
        request.predicate = predicate

        let context = try? container.fetch(request)
        return context as? [T]
    }
}
