//
//  FeatherConnectEntityTests.swift
//
//  Created by Denis Martin on 17/08/2017.
//

import Foundation

import XCTest
import CoreData
import FeatherConnect

@testable import FeatherBlogModule
@testable import FeatherConnect

class BlogPostConnectionTests: FeatherConnectEntityTests, EntityTesting {
    
    typealias T = BlogPost
    var frc     = NSFetchedResultsController<T>()
    
    override func setUp() {
        super.setUp()
        
        // Setup
        setupFetchController()
        
        // Fetch
        XCTAssertNoThrow(try frc.performFetch())
    }
    
    func test0Truncate() {
        if let storeURL = BlogModule.main.persistentContainer.persistentStoreCoordinator.persistentStores.first?.url {
            print(storeURL)
        }

        fireTruncate()
    }
    
    func test1stFireUpdate() { fireUpdate() }
    
    func test2ndFireUpdate() { fireUpdate(isSecondCall: true) }
    
    func test3FireUpdateImages() {
        if let storeURL = BlogModule.main.persistentContainer.persistentStoreCoordinator.persistentStores.first?.url {
            print(storeURL)
        }
        
        let fetchRequest: NSFetchRequest<BlogPost> = BlogPost.fetchRequest()
        let fetchedResults = try? BlogModule.main.persistentContainer.viewContext.fetch(fetchRequest)
        
        for result in  fetchedResults ?? [] {
            let networkUpdate   = self.expectation(description: "NetworkUpdate-\(result.id!)" )
            if let imageURL = result.imageURL {
                print("Downloading \(result.id!) - image: \(imageURL)")
            }
            result.getImage { data, error in
                if error == nil, let data = data {
                    print("Downloaded image for: \(result.id!) - Data: \(data.count/1000) kilobytes")
                    print("Entity imageData for: \(result.id!) - Data: \((result.imageData?.count ?? 0)/1000) kilobytes")
                }
                networkUpdate.fulfill()
            }
        }
        
        waitForExpectations(timeout: 20) { error in
            if let error = error {
                XCTFail(
                    "Error: \(error.localizedDescription)" +
                        " - Last updated: \(String(describing: T.lastUpdatedUserDefaultIdentfier()))" +
                        " - \(String(describing: T.lastUpdated()))"
                )
            }
        }
        
    }
    
    //    func testFetchSingle() {
    //        let postID = "BB386A7D-8B7E-4139-9D53-0345FF098974"
    //
    //        BlogPost.updateWith(identifier: postID) { (error) in
    //            XCTAssertNil(error, "Got: \(String(describing: error?.description))")
    //        }
    //    }
}
