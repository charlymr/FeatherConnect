//
//  File.swift
//  
//
//  Created by Denis Martin on 27/04/2021.
//

import SwiftyJSON
import CoreData
import Alamofire

/*
 {
     "bio": "<p>Denis</p>\r\n",
     "links": [
         {
             "url": "https://www.test.com",
             "label": "feather",
             "id": "84272742-B5EA-41D0-8B1E-4075B8060D7D",
             "priority": 100
         }
     ],
     "name": "Denis",
     "id": "194B5116-11F0-42C8-8608-02F3E6041C9F",
     "imageKey": "blog/authors/Dell Xmas 07 002_2.jpg"
 }
 */

extension BlogAuthor: ManagedEntity {
        
    public typealias FeatherModule = BlogModule
    
    public static let route: String = "authors"
    
    public static let routeFilteringParameters: String? = "?per=10000"

    public static let apiListItemsKey: String? = "items"

}
