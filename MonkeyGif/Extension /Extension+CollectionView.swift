//
//  Extension+CollectionView.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func setupCollectionView<Cell: UIView>(cell: Cell.Type,
                                              dataSource: UICollectionViewDataSource?,
                                              delegate: UICollectionViewDelegate?,
                                              layout: UICollectionViewCompositionalLayout) {
        register(Cell.toNib(), forCellWithReuseIdentifier: Cell.identifier)
        collectionViewLayout = layout
        self.dataSource = dataSource
        self.delegate = delegate
    }
}
