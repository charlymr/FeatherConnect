//
//  FeatherConnectEntityTests.swift
//
//  Created by Denis Martin on 17/08/2017.
//

import XCTest
import CoreData

@testable import FeatherConnect

protocol EntityTesting: NSFetchedResultsControllerDelegate {
    
    associatedtype T: Entity
    
    var frc: NSFetchedResultsController<T> { get set }
    
    var frcUpdate: XCTestExpectation? { get set }
    
}

extension EntityTesting where Self: XCTestCase, T: ManagedEntityMapped {
    
    func setupFetchController() {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        BlogModule.host = "http://127.0.0.1:8080"
        BlogModule.resetDataStore = true

        // Fetch all ELements
        let entityName      = String(describing: T.self)
        let fetchRequest: NSFetchRequest<T> =  NSFetchRequest(entityName: entityName )
        
        fetchRequest.sortDescriptors = [ NSSortDescriptor.init(key: "id", ascending: false) ]
        
        frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: BlogModule.main.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
    }
    
    func fireTruncate() {

        // Remove All elemetns
        XCTAssertNoThrow(try T.truncate(connection: BlogModule.main as! Self.T.FeatherModule))
        
        // Fetch Again
        try? self.frc.performFetch()
        
        // Check we have 0 elements
        if let objects = frc.fetchedObjects {
            XCTAssert(objects.isEmpty, "GOT: \(objects.count)")
            
        } else {
            XCTFail("We should have at least an empty array here")
        }
        
    }
    
    func fireUpdate(isSecondCall: Bool = false) {
        
        let networkUpdate   = self.expectation(description: "NetworkUpdate" + T.description() )
        
        T.update { (error, asChanges) in
            
            if isSecondCall == true {
                XCTAssert(asChanges == false, "Second call should not have changes")
                print("******************************** NO Changes from the server in the Second CALL... All good")
                networkUpdate.fulfill()
                return
            }
            
            if let error = error {
                XCTFail(error.localizedDescription)
                
            }
            
            // Fetch Agaim
            try? self.frc.performFetch()
            
            if asChanges == true, let objects = self.frc.fetchedObjects {
                XCTAssert(!objects.isEmpty, "GOT: \(objects.count)")
                print("******************************** UPDATE SUCCESSFUL: Fetched: \(objects.count) \(String(describing: T.self)) form the server")

            }
            networkUpdate.fulfill()
            
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail(
                    "Error: \(error.localizedDescription)" +
                        " - Last updated: \(String(describing: T.lastUpdatedUserDefaultIdentfier()))" +
                        " - \(String(describing: T.lastUpdated()))"
                )
            }
        }
        
    }

}

class FeatherConnectEntityTests: XCTestCase {
    
    var frcUpdate: XCTestExpectation?
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testManagedObjectContext() { XCTAssertNotNil(BlogModule.main.managedObjectContext) }
    
    // Will be call only if we have changes
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        frcUpdate?.fulfill()
    }
    
}
