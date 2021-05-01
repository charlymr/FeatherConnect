//
//  IRLEXEntity.swift
//
//  Created by Denis Martin on 27/12/2016.
//

import Foundation

import SwiftyJSON
import CoreData

extension  Entity {
    
    // MARK: MAppimg Helper
    
    internal func mapParent(_ json: JSON) {
        id              = json["id"].stringValue
        deletedOnServer = json["deleted_at"].stringValue.isEmpty ? false : true
    }
    
    public var objecId: String {
        return id ?? "ERROR"
    }

}
