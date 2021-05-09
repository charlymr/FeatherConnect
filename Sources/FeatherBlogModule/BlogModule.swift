//
//  FeatherConnect.swift
//
//  Created by Denis Martin on 13/12/2016.
//

@_exported import FeatherConnect

public final class BlogModule: Module, ModuleDefinitionProtocol {
    
    public init(for route: FeatherAPI) {
        self.persistentContainer = Self
            .persistentContainer( forResource: route.module, bundle:  Bundle.module, reset: Self.resetDataStore )
        super.init(withApiPath: route.rawValue, module: route.module)
    }
    
    public static var main: BlogModule = .init(for: FeatherAPI.blog)

    public let persistentContainer: NSPersistentContainer


}

