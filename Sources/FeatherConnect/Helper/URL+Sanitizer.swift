//
//  File.swift
//  
//
//  Created by Denis Martin on 27/04/2021.
//

public extension URL {

    static func sanatizedImageURL(from imageURL: String?) -> URL? {
        guard let imgURL = imageURL,
            let escapedString = imgURL.addingPercentEncoding(
                withAllowedCharacters: URL.csCopy),
            let url = URL(string: escapedString) else {
                return nil
            }
        return url
    }

    private static let csCopy = CharacterSet(bitmapRepresentation: CharacterSet.urlPathAllowed.bitmapRepresentation)

}
