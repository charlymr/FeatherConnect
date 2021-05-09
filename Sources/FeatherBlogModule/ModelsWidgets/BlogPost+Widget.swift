//
//  BlogPostWidget.swift
//  FeatherConnect
//
//  Created by Denis Martin on 31/01/2021.
//

#if os(iOS)
/// For the Widget to work, you will need AppGroup to be setup!
public struct BlogPostWidgetData: ModuleWidgetDataProtocol, Codable {
    public typealias Module             = BlogModule
    public typealias EntityType         = BlogPost
    public typealias Category           = BlogCategory
        
    public var objecId: String
    public var title: String
    public var subtitle: String
    public var image: Data?
    public var date_modified: Date

    public static let moduleName = "Blog"

    static public var placeholder: BlogPostWidgetData {
        let data = BlogPostWidgetData(objecId: "0",
                                       title: "Posts",
                                       subtitle: "All Posts on your screen",
                                       image: nil,
                                       date_modified: Date())
        return data
    }

    static public func from(blogPost: EntityType) -> BlogPostWidgetData {
        let data = BlogPostWidgetData(objecId: blogPost.id ?? "ERROR",
                                       title: blogPost.title ?? placeholder.title,
                                       subtitle: blogPost.excerpt ?? placeholder.subtitle,
                                       image: blogPost.imageData,
                                       date_modified: blogPost.updatedAt ?? placeholder.date_modified)
        return data
    }
        
    static public func sharedStoreURL(filename: String) -> URL? {
        guard Module.appGroup != nil else {
            fatalError("App Group value for BlogModule is not setup")
        }
        return BlogModule.sharedStoreURL(filename: filename)
    }

}

public class BlogPostFetcher: WidgetFetcher<BlogPostWidgetData, BlogPostWidgetData.EntityType> {

    // MARK: Fetch Controller
        
    static let sortDescriptors = [ NSSortDescriptor.init(key: "createdAt", ascending: false) ]

    // MARK: Ovveriding Filtering Logic
    
    public func allBlogPost(for category: String?) -> [BlogPostWidgetData] {
        if let category = category {
            selectedCategory = category
        }
        return allObjects
    }

    public func latestBlogPost(for category: String?) -> [BlogPostWidgetData] {
        if let category = category {
            selectedCategory = category
        }
        return latestObjects()
    }

    public required init(with fetcher: NSFetchedResultsController<BlogPost>) {
        super.init(with: Self.fetcherFor(category: "Toutes"))
    }
    
    // MARK: Categories Logic
    
    private var selectedCategory: String = "All" {
        didSet {
            fetcher = Self.fetcherFor(category: selectedCategory)
            fetcher.delegate = self
            try? fetcher.performFetch()
        }
    }

    private static func predicate(category: String? = nil) -> NSPredicate {
        guard let category = category, category != "Toutes" else {
            print("Post - Fetch with NO category")
            return NSPredicate(format: "deletedOnServer == false")
        }
        
        print("Post - Fetch with category: \(category)")
        return NSPredicate(format: "ANY categories.title in %@ AND deletedOnServer == false", category)
    }
    
    private static func fetcherFor(category: String?) -> NSFetchedResultsController <BlogPostWidgetData.EntityType> {

        let fetchRequest: NSFetchRequest<BlogPostWidgetData.EntityType> = BlogPostWidgetData.EntityType.fetchRequest()
        fetchRequest.sortDescriptors = Self.sortDescriptors
        fetchRequest.predicate = Self.predicate(category: category)
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: BlogModule.main.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        return frc

    }

    private var categoryPath: URL {
        BlogPostWidgetData.Module.sharedStoreURL(filename: "category.data")!
    }

    public func allCategories() -> [String] {
        /// Save current Fetcher category
        let currentCategory = self.selectedCategory
        
        /// Fetch and store all category titles
        let frc = Self.fetcherFor(category: nil)
        var categories = [String]()
        try? frc.performFetch()
        if let objects = frc.fetchedObjects {
            for blogPost in objects {
                if let postCategories = blogPost.categories {
                    let forCategories: [BlogPostWidgetData.Category] = Array(_immutableCocoaArray: postCategories)
                    for category in forCategories  {
                        if let tilte = category.title, !categories.contains(tilte) {
                            categories.append(tilte)
                        }
                    }
                }
            }
        }
        
        /// Saving logic
        if !categories.isEmpty,
           let data = try? JSONSerialization.data(withJSONObject: categories, options: .prettyPrinted) {
            try? data.write(to: categoryPath)
            
        } else if let data = try? Data.init(contentsOf: categoryPath),
           let blogPostStrings = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String] {
            categories = blogPostStrings
        }
        
        /// Restore current Fetcher category
        self.selectedCategory = currentCategory
        
        return categories
    }

}

#endif
