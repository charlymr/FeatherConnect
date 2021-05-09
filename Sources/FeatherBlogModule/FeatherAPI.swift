//
//  File.swift
//  
//
//  Created by Denis Martin on 09/05/2021.
//

public enum FeatherAPI : String, FeatherAPIProtocol {
    case blog = "api/blog"
    
    public var module: String {
        switch self {
        case .blog: return "Blog"
        }
    }
}
