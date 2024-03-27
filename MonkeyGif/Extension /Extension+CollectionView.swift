//
//  Extension+CollectionView.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func setupGifCollectionView(dataSource: UICollectionViewDataSource?, delegate: UICollectionViewDelegate?, layout: UICollectionViewCompositionalLayout) {
        register(GifViewCell.toNib(), forCellWithReuseIdentifier: GifViewCell.identifier)
        collectionViewLayout = layout
        self.dataSource = dataSource
        self.delegate = delegate
    }
}
