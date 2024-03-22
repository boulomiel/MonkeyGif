//
//  FavoriteControllerViewModel.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 21/03/2024.
//

import Foundation
import CoreData
import UIKit

class FavoriteViewControllerViewModel: NSObject, NSFetchedResultsControllerDelegate, FetchingViewModelProtocol {
    
    private var fetchedResultsController: NSFetchedResultsController<MGGif>?
    @Published var fetchState: FetchState<NSDiffableDataSourceSnapshot<Int, MGGif>>
    
    init(fetchedResultsController: NSFetchedResultsController<MGGif>? = nil) {
        self.fetchedResultsController = fetchedResultsController
        self.fetchState = .idle
        super.init()
        loadSavedData()
    }
    
    private func loadSavedData() {
        if fetchedResultsController == nil {
            let request = MGGif.fetchRequest()
            request.fetchBatchSize = 3
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: PersistenceController.shared.container.viewContext,
                sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.delegate = self
        }
        do {
            try fetchedResultsController?.performFetch()
            updateSnapshot()
        } catch {
            fetchState = .failure(.coreData(description: error.localizedDescription))
        }
    }
    
    private func updateSnapshot() {
        var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, MGGif>()
        diffableDataSourceSnapshot.appendSections([0])
        diffableDataSourceSnapshot.appendItems(fetchedResultsController?.fetchedObjects ?? [])
        fetchState = .fetched(diffableDataSourceSnapshot)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        updateSnapshot()
    }
}
