//
//  IRLServerIRLEntityConnectionTests.swift
//
//  Created by Denis Martin on 17/08/2017.
//

import Foundation

import XCTest
import CoreData

@testable import IRLServerConnection

class BlogPostConnectionTests: IRLServerIRLEntityConnectionTests, IRLEntityTesting {
    
    typealias T = BlogPost
    var frc     = NSFetchedResultsController<T>()
    
    override func setUp() {
        super.setUp()
        
        // Setup
        setupFetchController()
        
        // Fetch
        XCTAssertNoThrow(try frc.performFetch())
    }
    
    func testTruncate() { fireTruncate() }
    
    func test1stFireUpdate() { fireUpdate() }
    
    func test2ndFireUpdate() { fireUpdate(isSecondCall: true) }

//    func testFetchSingle() {
//        let postID = "BB386A7D-8B7E-4139-9D53-0345FF098974"
//
//        BlogPost.updateWith(identifier: postID) { (error) in
//            XCTAssertNil(error, "Got: \(String(describing: error?.description))")
//        }
//    }
}
