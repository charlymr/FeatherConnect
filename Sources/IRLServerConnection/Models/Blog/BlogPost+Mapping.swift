//
//  IRLEXNews.swift
//
//  Created by Denis Martin on 27/12/2016.
//

import SwiftyJSON
import CoreData
import Alamofire

/*
 {
 "excerpt": "Les montants des indemnités journalières dues aux exploitants en cas d'arrêt de travail sont revalorisés à compter du 1 avril 2021.",
 "imageKey": "uploads/v1/k4_17361511.jpg",
 "push_done": "Non",
 "content": "<h2><strong>Exploitants",
 "createdAt": "2021-04-20T12:00:00Z",
 "id": "BB386A7D-8B7E-4139-9D53-0345FF098974",
 "updatedAt": "2021-04-27T16:29:32Z",
 "push": false,
 "authors": [],
 "categories": [],
 "push_date": "2021-04-20T12:00:00Z",
 "title": "Exploitants agricoles : montant des indemnités journalières"
 }
 */
extension BlogPost: ManagedObjectServerMaping {
    
    public typealias FeatherModule = BlogModule

    public static let route: String = "posts"
    
    public static let routeFilteringParameters: String? = "?limit=10000"
    
    public static let apiListItemsKey: String? = "items"
    
    public func mapSiblings(_ json: JSON) {
        // Create/Map Authors/Categories
        authors = nil
        categories = nil
        // Here we would map the JSON object on the fly
        BlogAuthor.mapSiblings(key: "authors", json: json) { (author) in
            self.addToAuthors(author)
        }
        BlogCategory.mapSiblings(key: "categories", json: json) { (category) in
            self.addToCategories(category)
        }
        FeatherModule.main.saveContext()
    }

}

extension BlogPost {

}
