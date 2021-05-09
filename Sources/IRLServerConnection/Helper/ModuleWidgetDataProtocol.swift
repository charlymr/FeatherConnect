//
//  File.swift
//  
//
//  Created by Denis Martin on 29/04/2021.
//

import Foundation
import CoreData

#if os(iOS)
import UIKit

/// For the Widget to work, you will need AppGroup to be setup!

public protocol ModuleWidgetDataProtocol {
    associatedtype Module               = ModuleDefinitionProtocol
    associatedtype EntityType           = Entity & ManagedObjectServerMaping

    static func from(blogPost: EntityType) -> Self
    static var placeholder: Self { get }
    
    var objecId: String { get }
    var title: String { get }
    var subtitle: String { get }
    var image: Data? { get }
    var date_modified: Date { get }

}


public class WidgetFetcher<WidgetResultType, ManagedObjectType: Entity> : NSObject, NSFetchedResultsControllerDelegate
where WidgetResultType : ModuleWidgetDataProtocol  {
        
    public var fetcher: NSFetchedResultsController <ManagedObjectType>

    public func entityAt(index: Int) -> WidgetResultType {
        let blogPost =  fetcher.object(at: IndexPath(row: index, section: 0))
        return WidgetResultType.from(blogPost: blogPost as! WidgetResultType.EntityType)
    }
    
    // MARK: Data Source
    
    public func numberOfRows() -> Int {
        if let sections = fetchedResultsController().sections {
            let currentSection = sections[0]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    public func fetchedResultsController() -> NSFetchedResultsController <NSFetchRequestResult> {
        return fetcher as! NSFetchedResultsController<NSFetchRequestResult>
    }
    
    public var allObjects: [WidgetResultType] {
        let numberOfRow = numberOfRows()
        var allObjects = [WidgetResultType]()
        for minuteOffset in 0 ..< numberOfRow {
            let object = entityAt(index: minuteOffset)
            allObjects.append(object)
        }
        return allObjects
    }
    
    public func latestObjects(limit: Int = 3) -> [WidgetResultType] {
        let numberOfRow = numberOfRows() > limit ? limit : numberOfRows()
        if numberOfRow == 0 {
            return [WidgetResultType.placeholder, WidgetResultType.placeholder, WidgetResultType.placeholder]
        }
        var latesObjects = [WidgetResultType]()
        for minuteOffset in 0 ..< numberOfRow {
            let BlogPost = entityAt(index: minuteOffset)
            latesObjects.append(BlogPost)
        }
        return latesObjects
    }

    public required init(with fetcher: NSFetchedResultsController<ManagedObjectType>) {
        self.fetcher = fetcher
        super.init()
        self.fetcher.delegate = self
        try? fetcher.performFetch()
    }

}

#endif
