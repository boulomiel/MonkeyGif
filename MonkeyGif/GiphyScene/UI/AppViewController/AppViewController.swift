//
//  AppViewController.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 19/03/2024.
//

import UIKit
import Combine

protocol ViewControllerProtocol {
    func setupUI()
    func observeDataChanges()
}

class AppViewController: UIViewController, UISearchResultsUpdating, ViewControllerProtocol, CollectionRequestProtocol {
    
    @IBOutlet weak var emptyContent: EmptyCollectionView!
    @IBOutlet var collectionView: UICollectionView!
    private let viewModel: AppViewControllerViewModel
    private var subscriptions: Set<AnyCancellable>

    lazy var collectionDecorator: CollectionDecorator = {
        CollectionDecorator(holder: self)
    }()
    
    lazy var searchDisplayDecorator: SearchControllerDecorator = {
        SearchControllerDecorator(controller: self)
    }()
    
    var switchAction: UIAction {
        UIAction {[weak self] _ in
            self?.viewModel.toggleSearchState()
        }
    }
    
    init(viewModel: AppViewControllerViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateTrendingScroll()
    }

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text
    }

    func setupUI() {
        collectionDecorator.setup()
        searchDisplayDecorator.setup()
    }
    
    func observeDataChanges() {
        viewModel.$gifData
            .receive(on: DispatchQueue.main)
            .sink {[weak self] data in
                self?.collectionDecorator.update(data: data)
            }
            .store(in: &subscriptions)
        
        viewModel.errorEvent
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map { AppErrorModel(error: $0)}
            .sink {[weak self] error in
                self?.showAlert(error)
            }
            .store(in: &subscriptions)
        
        viewModel.$searchState
            .receive(on: DispatchQueue.main)
            .sink {[weak self] state in
                self?.searchDisplayDecorator.update(searchState: state)
            }
            .store(in: &subscriptions)
    }

    private func showAlert(_ model: AppErrorModel) {
        let alertVC = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alertVC.addAction(.init(title: Texts.Alert.action, style: .cancel))
        present(alertVC, animated: true)
    }
    
    @objc func showFavorites() {
        let favoriteVC =  FavoriteViewController(viewModel: .init())
        let vc = UINavigationController(rootViewController: favoriteVC)
        present(vc, animated: true)
    }
    
    @objc func request() {
        viewModel.updateTrendingScroll()
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
}


extension AppViewController: CollectionMenuInteractionProtocol {
    func save(gif: GifData) {
        viewModel.addToFavorite(gif)
    }
}
