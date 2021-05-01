//
//  IRLServerConnection.swift
//
//  Created by Denis Martin on 13/12/2016.
//

import Foundation
import Alamofire
import CoreData

public protocol ModuleDefinitionProtocol {
    
    /// Required: for the module to work.
    /// If you subclass `Module`, most of it will be handle
    
    static var host: String? { get }
    static var main: Self { get }
    var host: String { get }
    var apiPath: String { get }
    var module: String { get }
    var persistentContainer: NSPersistentContainer { get }
    
    init(for route: FeatherAPI)
    
    /// Optional, Default "Model"
    static var appGroup: String? { get }
    var baseURL: String? { get }
    var modelName: String { get }
}


public extension ModuleDefinitionProtocol  {
    
    // MARK: - Core Data stack

    func applicationWillTerminate() {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    @discardableResult
    func saveContext () -> Bool {
        
        let context = managedObjectContext
        
        if context.hasChanges {
            do {
                try context.save()
                return true
                
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                
            }
        }
        return true
    }
    
    // MARK: iOS 10+
    
    static func persistentContainer(forResource module: String, name: String = "Model", reset: Bool = false) -> NSPersistentContainer {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        guard let modelURL = Bundle.module.url(forResource: module, withExtension: "momd") else { fatalError() }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else { fatalError() }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model )
        container.loadPersistentStores(completionHandler: { (_, error) in
            var willReset = reset
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                //                fatalError("Unresolved error \(error), \(error.userInfo)")
                print("Unresolved error \(error), \(error.userInfo)")
                willReset = true
            }
            
            if willReset {
                self.reset(container: container)
                
                container.loadPersistentStores(completionHandler: { (_, error) in
                    if let error = error as NSError? {
                        fatalError("Unresolved error \(error), \(error.userInfo)")
                    }
                })
            }
            
        })
        return container
    }
    
    static func reset(container: NSPersistentContainer) {
        if let storeURL = container.persistentStoreCoordinator.persistentStores.first?.url {
            do {
                try container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            } catch {
                print(error)
            }
        }
    }
    
}

/// Optional, Default "Model"

public extension ModuleDefinitionProtocol  {

    // MARK: - Conveniance
    
    var baseURL: String? { "\(host)/" + apiPath }
    
    var modelName: String { "Model" }
    
    static var appGroup: String? { return nil }

}

/// AppGroup support. This will return the path for a giver filename

public extension ModuleDefinitionProtocol {

    // MARK: Returns a URL for the given app group
    static func sharedStoreURL(filename: String) -> URL? {
        guard
            let appGroup = Self.appGroup,
            let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            
            let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            return paths[0].appendingPathComponent("\(filename)")
        }
        
        return fileContainer.appendingPathComponent("\(filename)")
    }
    
}
