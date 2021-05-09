//
//  ManagedObjectServerMapingPrivate.swift
//
//  Created by Denis Martin on 27/12/2016.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

internal let isoDateFormatter = DateFormatter()
internal let headerDateFormatter = DateFormatter()

internal extension ManagedObjectServerMaping where Self: ManagedEntityMapped {
    
    static func setLastUpdated(date: Date) {
        if let lastUpdate = lastUpdatedUserDefaultIdentfier() {
            UserDefaults.standard.set(date, forKey: lastUpdate)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: CoreData reset
    
    static func _truncate(connection: FeatherModule) throws {
        
        // create the delete request for the specified entity
        let entityName      = String(describing: Self.self)
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> =  NSFetchRequest(entityName: entityName )
        let deleteRequest   = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // perform the delete
        do {
            try connection.managedObjectContext.execute(deleteRequest)
        } catch {
            throw(error)
        }
        
        // Remove last update
        if let lastUpdate = lastUpdatedUserDefaultIdentfier() {
            UserDefaults.standard.removeObject(forKey: lastUpdate)
            UserDefaults.standard.synchronize()
        }
        
        connection.saveContext()
        
    }
    
    static func _storeFetched(connection: FeatherModule, result: JSON, singleValue: Bool = false) {
        
        var current = result
        if !singleValue, let property = Self.apiListItemsKey {
            current = result[property]
        }
        if let results = current.array {
            for json in results {
                _store(json: json, connection: connection)
            }
            
        } else {
            _store(json: current, connection: connection, mapSiblings: true)
        }

    }
    
    @discardableResult
    static func _store( json: JSON, connection: FeatherModule, saveContext: Bool = true, mapSiblings: Bool = false) -> Self? {
        
        var result: Self?   = nil
        let primary         = primaryKey(connection: connection) ?? "id"
        let identifier      = json[primary].stringValue

        // if there have any result, we just udpate
        if var found = _find(identifier: identifier, connection: connection) {
            
            // If deleted we remove our object from our DB
            if json["deletedAt"].stringValue.count > 1 {
                connection.managedObjectContext.delete(found)
            }
            // Map contect
            else {
                found.mapParent(json)
                if found.autoMapProperties() { found._autoMapContent(json) }
                found.mapContent(json)
                if mapSiblings { found.mapSiblings(json) }
                result = found
            }
        }
        
        // else, we create it like this (If not a deleted one)
        else if  json["deletedAt"].stringValue.count == 0 {
            
            let entityName      = String(describing: Self.self)
            guard var entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: connection.managedObjectContext) as? Self else {
                return nil
            }
            entity.mapParent(json)
            if entity.autoMapProperties() { entity._autoMapContent(json) }
            entity.mapContent(json)
            if mapSiblings { entity.mapSiblings(json) }
            result = entity
        }
        if saveContext {
            connection.saveContext()
        }
        return result
    }
    
    static func _find(identifier: String, connection: FeatherModule) -> Self? {
        let primary         = primaryKey(connection: connection) ?? "id"
        let predicate       = NSPredicate(format: "%K == %@", primary, identifier)
        let entityName      = String(describing: Self.self)
        let fetchRequest: NSFetchRequest<Self> =  NSFetchRequest(entityName: entityName )
        fetchRequest.predicate = predicate
        let fetchedResults = try? connection.managedObjectContext.fetch(fetchRequest)
        return fetchedResults?.first
    }
    
    static  func _updateData(fromSavedUrl url: String,
                             to: TimeInterval? = nil,
                             from: TimeInterval? = nil,
                             callback: ((JSON?, NSError?) -> Void)?) {
        
        // URL
        var urlWithParam = url
        
        // Headers if provided
        /// Here I would prefer to use the header and get the info in the headers, so we could use HEAD first.
        /// Need to be implemented in Feather
        let headers: HTTPHeaders = [:]
        
        // Modified From
        if let modifiedFrom = from {
            urlWithParam += "&start=\(String( Int(modifiedFrom) ))"
        }
        
        // Modified To
        if let modifiedTo = to {
            urlWithParam += "&end=\(String( Int(modifiedTo) ))"
        }

        // Request
        AF.request(urlWithParam, method: .get, headers: headers).responseJSON { (responseData) -> Void in
            
            if let error = responseData.error as NSError? {
                callback?(nil, error)
                
            } else if let _json  = responseData.data {
                
                let json = JSON(_json)
                callback?(json, nil)

                headerDateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
                
                // Save last update if any
                if  let headers      = responseData.response?.allHeaderFields,
                    let current     = headers["Date"] as? String,
                    let date        = headerDateFormatter.date(from: current) {
                    Self.self.setLastUpdated(date: date )
                }
                
            }
        }
        
    }
    
    func _getImageData(callback: ((Data?, NSError?) -> Void)?) {
        
        guard let url = self.imageURL else {
            callback?(nil, NSError.init(domain: "Failed to imageURL(From \(imageURL?.absoluteString ?? "Is Empty"))", code: 500, userInfo: nil))
            return
        }
        
        var muttatingSelf = self
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            guard error == nil else {
                callback?(nil, error! as NSError)
                return
            }
            if let data = data, data.count > 5126 {
                muttatingSelf.imageData = data
                callback?(data, nil)
            } else {
                callback?(nil, NSError.init(domain: "Did not get proper data. No data and No error. This should not happen!", code: 500, userInfo: nil))
            }
        }).resume()

    }
    
    func _autoMapContent(_ json: JSON) {
        _mapContent(with: json)
    }

    func _mapContent(with json: JSON) {

        isoDateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        for  (name, attribute) in entity.attributesByName where json[name] != JSON.null {
            
            switch attribute.attributeType {
            
            case  .integer16AttributeType:
                setValue( json[name].int16Value, forKey: name)
                
            case  .integer32AttributeType:
                setValue( json[name].int32Value, forKey: name)
                
            case .integer64AttributeType:
                setValue( json[name].int64Value, forKey: name)
                
            case .decimalAttributeType:
                setValue( json[name].numberValue.decimalValue, forKey: name)
                
            case .doubleAttributeType:
                setValue( json[name].doubleValue, forKey: name)
                
            case .floatAttributeType:
                setValue( json[name].floatValue, forKey: name)
                
            case .stringAttributeType:
                setValue( json[name].stringValue, forKey: name)
                
            case .booleanAttributeType:
                setValue( json[name].boolValue, forKey: name)
                
            case .UUIDAttributeType:
                setValue( UUID(uuidString: json[name].stringValue), forKey: name)
                
            case  .dateAttributeType:
                setValue( isoDateFormatter.date(from: json[name].string ?? ""), forKey: name)
                
            default:
                break
            }
        }
    }
    
}
