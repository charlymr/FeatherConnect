//
//  File.swift
//  
//
//  Created by Denis Martin on 27/04/2021.
//

import Foundation
#if os(iOS)
import UIKit

public protocol ImageCaching {
    var objecId: String { get }
    var imageURL: String? { get }
    static var moduleName: String { get }
    static func sharedStoreURL(filename: String) -> URL?
}

public extension ImageCaching {
        
    var image: UIImage? {
        guard let url = imagePath, let data = try? Data.init(contentsOf: url) else {
            return nil
        }
        return UIImage.init(data: data)
    }
    
    func cacheImage(imageData: Data? = nil, sanitized: Bool = true) {
        if let imageData = imageData {
            saveImage(imageData: imageData)
            return
        }

        guard let imageURL = imageURL,
              let url = sanitized ?
                URL.sanatizedImageURL(from: imageURL) :
                URL(string: imageURL),
              image == nil
              else {
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            if let data = data, error == nil {
                guard data.count > 277 else {
                    self.cacheImage(imageData: nil, sanitized: false)
                    return
                }
                saveImage(imageData: data)
            }
        }).resume()
    }

    var sanatizedImageURL: URL? {
        return URL.sanatizedImageURL(from: imageURL)
    }

    func saveImage(imageData: Data) {
        guard let imagePath = imagePath else {
            return
        }
        print(imagePath)
        DispatchQueue.global().async {
            try? imageData.write(to: imagePath)
        }
    }

    var imagePath: URL? {
        guard URL.sanatizedImageURL(from: imageURL) != nil else {
            return nil
        }
        return Self.sharedStoreURL(filename: "\(Self.moduleName)-img-\(objecId)-img.data")
    }
    
}

public extension ImageCaching where Self: ManagedObjectServerMaping {
    static var moduleName: String {
        FeatherModule.main.module
    }
    static func sharedStoreURL(filename: String) -> URL? {
        FeatherModule.sharedStoreURL(filename: filename)
    }
}
#endif
