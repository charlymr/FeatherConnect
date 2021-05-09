//
//  FeatherConnect.swift
//
//  Created by Denis Martin on 13/12/2016.
//

import Foundation
import CoreData

public final class BlogModule: Module, ModuleDefinitionProtocol {

    public static var main: BlogModule = .init(for: .blog)

    public let persistentContainer: NSPersistentContainer
        
    public init(for route: FeatherAPI) {
        self.persistentContainer = Self.persistentContainer(forResource: route.module, reset: Self.resetDataStore )
        super.init(withApiPath: route.rawValue, module: route.module)
    }

}

