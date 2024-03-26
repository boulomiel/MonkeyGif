//
//  FavoriteDecoratorProtocol.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 21/03/2024.
//

import Foundation
import UIKit

@objc protocol CollectionFavoriteProtocol {
    var emptyFavoriteView: EmptyCollectionView! { get}
    var collectionView: UICollectionView! { get}
    func backButtonAction()
}

class FavoriteDecoratorProtocol: NSObject, DecoratorProtocol {
    
    typealias Holder = (UIViewController & CollectionFavoriteProtocol)?
    
    weak var holder: Holder
    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, MGGif>?
    
    private var collectionView: UICollectionView? {
        holder?.collectionView
    }
    
    private var emptyContent: EmptyCollectionView? {
        holder?.emptyFavoriteView
    }
    
    init(holder: Holder) {
        self.holder = holder
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        guard let collectionView , let emptyContent else { return }
        diffableDataSource = UICollectionViewDiffableDataSource<Int, MGGif>(collectionView: collectionView) { (view, indexPath, item) -> UICollectionViewCell? in
            let cell = view.dequeueReusableCell(withReuseIdentifier: GifViewCell.identifier, for: indexPath) as! GifViewCell
            do {
                let data = try item.toGIfData()
                cell.setup(gifData: data)
            } catch {
                print(#function, error.localizedDescription, "cannot display a cell with no url")
                cell.isHidden = true
            }
            return cell
        }
        collectionView.setupGifCollectionView(dataSource: diffableDataSource, delegate: nil)
        emptyContent.setEmptyType(.favorite)
        setupNavigationBar()
    }

    func update(data: NSDiffableDataSourceSnapshot<Int, MGGif>) {
        diffableDataSource?.apply(data, animatingDifferences: true)
        collectionView?.reloadData()
        holder?.emptyFavoriteView.isHidden = !data.itemIdentifiers.isEmpty
    }
    
    private func setupNavigationBar() {
        guard let holder  else { return }
        holder.navigationItem.leftBarButtonItem = .init(image: .init(sf: .chevronLeft), style: .plain, target: holder, action: #selector(holder.backButtonAction))
    }
}
