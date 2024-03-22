//
//  FavoriteViewController.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import UIKit
import Combine

class FavoriteViewController: UIViewController, ViewControllerProtocol, CollectionFavoriteProtocol {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyFavoriteView: EmptyCollectionView!
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, MGGif>?
    private let viewModel: FavoriteViewControllerViewModel
    private var subscriptions: Set<AnyCancellable> = .init()
    
    lazy var favoriteDecorator: FavoriteDecoratorProtocol = {
        FavoriteDecoratorProtocol(holder: self)
    }()
    
    init(viewModel: FavoriteViewControllerViewModel) {
        self.viewModel = viewModel
        self.subscriptions = .init()
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeDataChanges()
    }

    func setupUI() {
        favoriteDecorator.setup()
    }
    func observeDataChanges() {
        viewModel.$dataSnapShot
            .receive(on: DispatchQueue.main)
            .sink {[weak self] snaphost in
                self?.favoriteDecorator.update(data: snaphost)
            }
            .store(in: &subscriptions)
    }

    @objc func backButtonAction() {
        self.dismiss(animated: true)
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
}
