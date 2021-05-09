//
//  Entity.swift
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
        deletedOnServer = json["deletedAt"].stringValue.isEmpty ? false : true
        imageKey        = json["imageKey"].stringValue
    }
    
    public var objecId: String {
        return id ?? "ERROR"
    }

}

#if os(iOS)
import UIKit

extension Entity {
    public var image: UIImage? {
        guard let data = imageData else {
            return nil
        }
        return UIImage(data: data)
    }
}
#endif

#if os(macOS)
import Cocoa

extension Entity {
    public var image: CIImage? {
        guard let data = imageData else {
            return nil
        }
        return CIImage(data: data)
    }
}
#endif
