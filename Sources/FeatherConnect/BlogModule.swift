//
//  FeatherConnect.swift
//
//  Created by Denis Martin on 13/12/2016.
//

import Foundation
import CoreData

public enum FeatherAPI : String, FeatherAPIProtocol {
    case blog = "api/blog"
    public var module: String {
        switch self {
        case .blog: return "Blog"
        }
    }
}

public final class BlogModule: Module, ModuleDefinitionProtocol {

    public static var main: BlogModule = .init(for: FeatherAPI.blog)

    public let persistentContainer: NSPersistentContainer
        
    public init(for route: FeatherAPIProtocol) {
        self.persistentContainer = Self.persistentContainer(forResource: route.module, reset: Self.resetDataStore )
        super.init(withApiPath: route.rawValue, module: route.module)
    }

}

