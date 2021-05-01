//: [Previous](@previous)

import PlaygroundSupport
import CoreData
import IRLServerConnection

/// Update With You server
BlogModule.host = "http://127.0.0.1:8080"

/// Use those 2 method if you want to clean up your DB. (This for debug purposes)
//BlogModule.resetDataStore = true
//try! BlogPost.truncate(connection: BlogModule.main)


URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

// Load our stuffs
PlaygroundPage.current.needsIndefiniteExecution = true
print("BlogPost DB: has data up to: \(String(describing: BlogPost.lastUpdated()))")

BlogPost.update {  (error, hasUpdate) in
    if let error = error {
        print(error)
    }
    
    print(hasUpdate ? "Changes detected & Sync." : "No changes since last Sync: \(String(describing: BlogPost.lastUpdated()))")
    
    // let predicate = NSPredicate(format: "%K == %i", "id", Int(1) )
    let fetchRequest: NSFetchRequest<BlogPost> = BlogPost.fetchRequest()
    // fetchRequest.predicate = predicate
    
    guard let fetchedResults = try? BlogModule.main.managedObjectContext.fetch(fetchRequest) else {
        PlaygroundPage.current.finishExecution()
    }
    
    print(fetchedResults.count)
    for result in fetchedResults {
        if let postID = result.id {
            BlogPost.updateWith(identifier: postID) { (_) in
                print("Fetch: " + postID)

                let predicate = NSPredicate(format: "%K == %@", "id", postID )
                let singleFetchRequest: NSFetchRequest<BlogPost> = BlogPost.fetchRequest()
                singleFetchRequest.predicate = predicate
                guard let singleFetchedResults = try? BlogModule.main.managedObjectContext.fetch(singleFetchRequest) else {
                    PlaygroundPage.current.finishExecution()
                }
                print(singleFetchedResults.first.debugDescription)
            }
        }
    }
}

DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
    let fetchRequest: NSFetchRequest<BlogPost> = BlogPost.fetchRequest()
    let fetchedResults = try? BlogModule.main.persistentContainer.viewContext.fetch(fetchRequest)
    print(fetchedResults?.count ?? 0)
    for result in fetchedResults ?? [] {
        print(result.id ?? "")
        print(result.debugDescription)

        print("Show Catgory of: \(result.id ?? "")")
        if let objects = result.categories,
           let objects_array = Array(objects) as? [BlogCategory] {
            for object in objects_array {
                print(object.id ?? "")
                print(object.debugDescription)
            }
        }
        print("Show Authors of: \(result.id ?? "")")
        if let objects = result.authors,
           let objects_array = Array(objects) as? [BlogAuthor] {
            for object in objects_array {
                print(object.id ?? "")
                print(object.debugDescription)
            }
        }
    }

    PlaygroundPage.current.finishExecution()

}
