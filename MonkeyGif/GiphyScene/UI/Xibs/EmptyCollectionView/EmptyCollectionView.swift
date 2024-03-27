//
//  EmptyCollectionView.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 21/03/2024.
//

import UIKit

class EmptyCollectionView: XibView {
    
    enum EmptyType {
        case all, favorite, idle
        
        var label: String {
            switch self {
            case .all:
                Texts.EmptySearch.all
            case .favorite:
                Texts.EmptySearch.favorites
            case .idle:
                Texts.EmptySearch.idle
            }
        }
        
        var image: UIImage {
            switch self {
            case .all:
                    .init(sf: .camera)
            case .favorite:
                    .init(sf: .star)
            case .idle:
                    .init(sf: .loading)
            }
        }
    }
    
    private var emptyType: EmptyType = .idle {
        didSet {
            self.imageView?.image = emptyType.image
            self.labelView?.text = emptyType.label
        }
    }
    
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    func setEmptyType(_ emptyType: EmptyType) {
        self.emptyType = emptyType
    }
}
