//
//  File.swift
//  
//
//  Created by Denis Martin on 28/04/2021.
//

open class Module {
        
    public static var host: String?     = nil
    public static var appGroup: String? = nil
    public static var resetDataStore: Bool = false

    public let host: String
    public let apiPath: String
    public let module: String

    public init(withApiPath apiPath: String, module: String) {
        guard let host = Self.host else { Self.fatalInitializationError() }
        self.host                = host
        self.apiPath             = apiPath
        self.module              = module
    }
    
    private init() {
        fatalError("init() has not been implemented")
    }
    
    static private func fatalInitializationError() -> Never {
        fatalError("\(Self.self) doesn't know your endpoint. You must set the Host before using the module. \nEx. \(Self.self).host = \"http://127.0.0.1:8080\"")
    }
    
}

