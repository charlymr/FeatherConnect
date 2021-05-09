//: [Previous](@previous)

import PlaygroundSupport
import FeatherBlogModule

BlogModule.host = "http://127.0.0.1:8080"

PlaygroundPage.current.needsIndefiniteExecution = true

let fetchRequest: NSFetchRequest<BlogPost> = BlogPost.fetchRequest()
let fetchedResults = try? BlogModule.main.persistentContainer.viewContext.fetch(fetchRequest)
print(fetchedResults?.count ?? 0)

BlogPost.update {  (_, _) in
    let fetchedResults = try? BlogModule.main.persistentContainer.viewContext.fetch(fetchRequest)
    print(fetchedResults?.count ?? 0)
    for result in fetchedResults ?? [] {
        print(result.debugDescription)
    }
    PlaygroundPage.current.finishExecution()
}

//: [Next](@next)
