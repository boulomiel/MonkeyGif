//
//  UIKit.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import Foundation
import UIKit
import CoreData

@objc protocol CollectionRequestProtocol {
    var collectionView: UICollectionView! { get}
    var emptyContent: EmptyCollectionView! { get }
    var switchAction: UIAction { get }
    func request()
    func showFavorites()
}

protocol CollectionMenuInteractionProtocol {
    func save(gif: GifData)
}


class CollectionDecorator: NSObject, DecoratorProtocol {
    
    typealias Holder = (CollectionRequestProtocol & CollectionMenuInteractionProtocol & UIViewController)?
    
    weak var holder: Holder
    private var data: [GifData]
    private lazy var refreshControl: UIRefreshControl = {
        var rc = UIRefreshControl()
        if let holder = holder {
            rc.addTarget(holder, action: #selector(holder.request), for: .valueChanged)
        }
        return rc
    }()
    
    private var collectionView: UICollectionView? {
        holder?.collectionView
    }
    
    private var emptyContent: EmptyCollectionView? {
        holder?.emptyContent
    }
    
    init(holder: Holder) {
        self.holder = holder
        self.data = []
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupNavigationBar()
        emptyContent?.setEmptyType(.idle)
        collectionView?.setupGifCollectionView(dataSource: self, delegate: self, layout: .MultipleItemLayout)
        collectionView?.refreshControl = refreshControl
    }

    func update(data: [GifData]) {
        self.data = data
        self.collectionView?.reloadData()
        self.refreshControl.endRefreshing()
        self.emptyContent?.setEmptyType(.all)
        let t: CGFloat = data.isEmpty ? 0.8 : 0
        UIView.animateBouncy(withDuration: 0.3) {[weak self] in
            
            self?.emptyContent?.transform = .init(scaleX: t, y: t)
        } completion: { [weak self] _ in
            UIView.animateBouncy(withDuration: 0.5) {
                self?.emptyContent?.transform = t > 0 ? .identity : .init(scaleX: 0, y: 0)
                self?.emptyContent?.isHidden = !data.isEmpty
            }
        }
    }
    
    func makeSwitch() -> UISwitch {
        let toggle = UISwitch()
        if let holder = holder {
            toggle.addAction(holder.switchAction, for: .valueChanged)
        }
        return toggle
    }
    
    private func setupNavigationBar() {
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().backgroundColor = .black
        guard let holder = holder else { return }
        holder.navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(sf: .star), style: .plain, target: holder, action: #selector(holder.showFavorites))
        holder.navigationItem.leftBarButtonItem = .init(customView: makeSwitch())
    }
    
    private func contextMenu(gifData: GifData) -> UIMenu {
        let favorite = UIAction(title: Texts.Collection.Context.addToFavoriteAction, image: UIImage(sf: .star)) {[weak self] action in
            self?.holder?.save(gif: gifData)
        }
        return UIMenu(title: Texts.Collection.Context.title, children: [favorite])
    }
}


extension CollectionDecorator: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifViewCell.identifier, for: indexPath) as! GifViewCell
        cell.setup(gifData: data[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        if let firstIndex =  indexPaths.first {
            return UIContextMenuConfiguration(actionProvider:  {[weak self] suggestedActions in
                self?.contextMenu(gifData: self!.data[firstIndex.item])
            })
        } else {
            return nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if data.count > 49, indexPath.item == data.count - 1  {
            holder?.request()
        }
    }
}
