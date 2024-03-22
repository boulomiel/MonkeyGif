//
//  Extension+MGGif.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import Foundation
import CoreData

extension MGGif {
    convenience init(context: NSManagedObjectContext,
                     isFavorite: Bool,
                     url: String,
                     imageID: UUID
    ) {
        self.init(context: context)
        self.isFavourite = isFavorite
        self.url = url
        self.imageId = imageID
        self.date = .now
    }
    
    func toGIfData() -> GifData {
        GifData(imageId: imageId ?? .init(),
                url: url ?? "",
                isFavorite: isFavourite)
    }
}
