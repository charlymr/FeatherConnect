//
//  ManagedObjectServerMaping.swift
//
//  Created by Denis Martin on 14/12/2016.
//

public typealias ManagedEntityMapped = NSManagedObject & EntityProtocol & ManagedObjectServerMaping

public protocol ManagedObjectServerMaping : NSFetchRequestResult {

    // MARK: Required
    
    associatedtype FeatherModule: ModuleDefinitionProtocol
    
    static var route: String { get }
    
    static var routeFilteringParameters: String? { get }
    
    // MARK: Optional
    
    static var apiListItemsKey: String? { get }

    static func lastUpdatedUserDefaultIdentfier() -> String?

    func autoMapProperties() -> Bool

    func mapContent(_ json: JSON)
    
    func mapSiblings(_ json: JSON)

}

public extension ManagedObjectServerMaping where Self: ManagedEntityMapped {

    // MARK: Primary key definition
    
    static func primaryKey(connection: FeatherModule = FeatherModule.main ) -> String? {
        let entityName      = String(describing: Self.self)
        let entityDescr     = NSEntityDescription.entity(forEntityName: entityName, in: connection.managedObjectContext)
        let primary         = entityDescr?.userInfo?["Primary"] as? String
        return primary
    }
    
    static func lastUpdatedUserDefaultIdentfier() -> String? {
        let entityName      = String(describing: Self.self)
        return "com.feather.FeatherConnect.\(FeatherModule.main.module).\(entityName).lastUpdated"
    }
        
    static func lastUpdated() -> Date? {
        if let lastUpdate = lastUpdatedUserDefaultIdentfier(),
           let date = UserDefaults.standard.value(forKey: lastUpdate) as? Date {
            return date
        }
        return nil
    }
    
    var imageURL: URL? {
        guard let imageKey = imageKey else {
            return nil
        }
        return URL(string: FeatherModule.main.host + "/assets/" + imageKey)
    }

    // MARK: Work with Data
    
    static func truncate(connection: FeatherModule) throws {
        do { try self._truncate(connection: connection) } catch { throw error }
    }
    
    static func update(connection: FeatherModule = FeatherModule.main ,
                       completionHandler: ((NSError?, _ asChanges: Bool) -> Void)?) {
        
        guard let base = connection.baseURL else {
            fatalError("No BaseURL in FeatherConnect")
        }
        
        _updateData(fromSavedUrl: "\(base)/\(route)/\(Self.routeFilteringParameters ?? "")",
                    from: lastUpdated()?.timeIntervalSince1970 ) { (results, error) in
            
            if let error = error {
                completionHandler?(error, false)
            }
            if let json = results {
                let asChanges: Bool
                if let property = Self.apiListItemsKey {
                    asChanges = !json[property].isEmpty
                } else {
                    asChanges = true
                }
                self._storeFetched(connection: connection, result: json )
                completionHandler?(nil, asChanges)
            }

        }
    }
    
    static func updateWith(identifier: String,
                           connection: FeatherModule = FeatherModule.main ,
                           completionHandler: ((NSError?) -> Void)?) {
        
        guard let base = connection.baseURL else {
            fatalError("No BaseURL in FeatherConnect")
        }
        
        _updateData(fromSavedUrl: "\(base)/\(route)/\(identifier)") { (results, error) in
            
            if let error = error {
                completionHandler?(error)
            }
            if let json = results {
                self._storeFetched(connection: connection, result: json, singleValue: true )
                completionHandler?(nil)
            }
            
        }
    }
    
    static func mapSiblings(key: String,
                            json: JSON,
                            connection: FeatherModule = FeatherModule.main,
                            loopCallBack: ((Self) -> Void)?) {
        if let siblings = json[key].array {
            for sibilingJson in siblings {
                if let sibling = Self._store(json: sibilingJson, connection: connection, saveContext: false) {
                    loopCallBack?(sibling)
                }
            }
        }
    }

    func getImage(callback: ((Data?, NSError?) -> Void)?) {
        _getImageData(callback: callback)
    }
    
    // MARK: Optional Perform Personalisation
    
    func autoMapProperties() -> Bool {
        return true
    }

    func mapContent(_ json: JSON) {
        /// Convenient Place holder if the user want to ignore this
    }
    
    func mapSiblings(_ json: JSON) {
        /// Convenient Place holder if the user want to ignore this
    }
     
    static var routeFilteringParameters: String? { nil }

    static var apiListItemsKey: String? { nil}

}
