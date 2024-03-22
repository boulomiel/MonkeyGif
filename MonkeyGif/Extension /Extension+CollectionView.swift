//
//  Extension+CollectionView.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func setupGifCollectionView(dataSource: UICollectionViewDataSource?, delegate: UICollectionViewDelegate?) {
        register(GifViewCell.toNib(), forCellWithReuseIdentifier: GifViewCell.identifier)
        collectionViewLayout = UICollectionViewCompositionalLayout.ThreeLineLayout
        self.dataSource = dataSource
        self.delegate = delegate
    }
}
