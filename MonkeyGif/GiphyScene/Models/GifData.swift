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
    let url: String
    let isFavorite: Bool
    
    func toGifModel(context: NSManagedObjectContext) -> MGGif {
        MGGif(context: context, isFavorite: isFavorite, url: url, imageID: imageId)
    }
}
