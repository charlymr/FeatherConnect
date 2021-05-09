//
//  File.swift
//  
//
//  Created by Denis Martin on 28/04/2021.
//

import Foundation

public enum FeatherAPI : String {
    case blog = "api/blog"
    var module: String {
        switch self {
        case .blog: return "Blog"
        }
    }
}

