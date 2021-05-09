//
//  Entity.swift
//
//  Created by Denis Martin on 27/12/2016.
//

import Foundation

import SwiftyJSON
import CoreData

public typealias ManagedEntityMapped = NSManagedObject & EntityProtocol & ManagedObjectServerMaping

public protocol EntityProtocol {
    var id: String? { get set }
    var deletedOnServer: Bool { get set }
    var imageKey: String? { get set }
    var imageData: Data? { get set }
}

extension EntityProtocol {
    
    // MARK: MAppimg Helper
    
    internal mutating func mapParent(_ json: JSON) {
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

extension EntityProtocol {
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

extension EntityProtocol  {
    public var image: CIImage? {
        guard let data = imageData else {
            return nil
        }
        return CIImage(data: data)
    }
}
#endif
