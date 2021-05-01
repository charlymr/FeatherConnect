//: [Previous](@previous)

import CoreData
import IRLServerConnection

BlogModule.host = "http://127.0.0.1:8080"

let fetchRequest: NSFetchRequest<BlogPost> = BlogPost.fetchRequest()

let fetchedResults = try? BlogModule.main.persistentContainer.viewContext.fetch(fetchRequest)
print(fetchedResults?.count ?? 0)

BlogPost.update {  (_, _) in
    let fetchedResults = try? BlogModule.main.persistentContainer.viewContext.fetch(fetchRequest)
    print(fetchedResults?.count ?? 0)
    for result in fetchedResults ?? [] {
        print(result.debugDescription)
    }
}

//: [Next](@next)
