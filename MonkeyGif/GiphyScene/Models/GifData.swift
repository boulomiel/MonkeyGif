//
//  GifData.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 21/03/2024.
//

import Foundation
import CoreData

struct GifData {
    let imageId: UUID
    let url: URL
    let isFavorite: Bool
    
    init(imageId: UUID, url: URL?, isFavorite: Bool) throws {
        self.imageId = imageId
        self.isFavorite = isFavorite
        guard let url = url else {
            throw AppError.url(description: "URL is not valie at \(#function)")
        }
        self.url = url
    }
    
    func toGifModel(context: NSManagedObjectContext) -> MGGif {
        MGGif(context: context, isFavorite: isFavorite, url: url, imageID: imageId)
    }
}
