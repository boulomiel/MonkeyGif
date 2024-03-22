//
//  AppViewControllerViewModel.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import Foundation
import Combine
import CoreData
import UIKit
import AsyncAlgorithms

class AppViewControllerViewModel: NSObject, FetchingViewModelProtocol {
        
    private let apiKey: String
    private let interactor: ApiInteractor
    private var currentCount: Int
    @Published var searchState: SearchState
    @Published var searchText: String?
    @Published var fetchState: FetchState<[GifData]>
    
    var endPoints: EndPoints {
        let reader = PlistReader(keyList: .endPoint)
        return reader.read()
    }
    
    init(apiKey: String, interactor: ApiInteractor) {
        self.apiKey = apiKey
        self.interactor = interactor
        self.currentCount = 0
        self.fetchState = .idle
        self.searchState = .global
        super.init()
        observeSearch()
    }
    
    func addToFavorite(_ gif: GifData) {
        Task {
            do {
                try await interactor.save(gif)
            } catch {
                fetchState = .failure(.coreData(description: error.localizedDescription))
            }
        }
    }
    
    func observeSearch() {
        #if CANCALL
        Task { [weak self] in
            guard let self = self else { return }
            let result = self.$searchText
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .debounce(for: 0.8, scheduler: DispatchQueue.main)
                .values
                .map { search in
                    switch self.searchState {
                    case .global:
                        return await self.interactor.searchGif(.init(apiKey: self.apiKey, path: self.endPoints.search, limit: 50, q: search, offset: 0))
                    case .byId:
                        return await self.interactor.getGifById(.init(apiKey: self.apiKey, gifId: search, path: self.endPoints.getById))
                    }
                }
            for await r in result {
                switch r {
                case .success(let success):
                    self.fetchState = .fetched(success)
                case .failure(let failure):
                    self.fetchState = .failure(failure)
                }
            }
        }
        #endif
    }
    
    func updateTrendingScroll() {
        #if CANCALL
        Task {[weak self] in
            guard let self = self else { return }
            let result =  await interactor.fetchTrending(.init(apiKey: apiKey, path: endPoints.trending, limit: 50, offset: currentCount))
            switch result {
            case .success(let success):
                await MainActor.run {
                    if case let .fetched(data) = self.fetchState {
                        self.fetchState = .fetched(success+data)
                    } else {
                        self.fetchState = .fetched(success)
                    }
                    self.currentCount += 50
                }
            case .failure(let failure):
                self.fetchState = .failure(failure)
            }
        }
        #endif
    }
    
    func toggleSearchState() {
        searchState = searchState == .global ? .byId : .global
    }
}


