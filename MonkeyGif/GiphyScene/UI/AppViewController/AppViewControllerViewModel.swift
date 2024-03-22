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

class AppViewControllerViewModel: NSObject, ObservableObject {
    
    private let apiKey: String
    private let interactor: ApiInteractor
    private var currentCount: Int
    @Published var searchState: SearchState
    @Published var searchText: String?
    @Published private (set) var gifData: [GifData]
    private (set) var errorEvent: PassthroughSubject<AppError, Never>
    
    var endPoints: EndPoints {
        let reader = PlistReader(keyList: .endPoint)
        return reader.read()
    }
    
    init(apiKey: String, interactor: ApiInteractor) {
        self.apiKey = apiKey
        self.interactor = interactor
        self.currentCount = 0
        self.gifData = []
        self.searchState = .global
        self.errorEvent = .init()
        super.init()
        observeSearch()
    }
    
    func addToFavorite(_ gif: GifData) {
        Task {
            do {
                try await interactor.save(gif)
            } catch {
                errorEvent.send(.coreData(description: error.localizedDescription))
            }
        }
    }
    
    func observeSearch() {
        #if CANCALL
        Task {
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
                    self.gifData = success
                case .failure(let failure):
                    self.errorEvent.send(failure)
                }
            }
        }
        #endif
    }
    
    func updateTrendingScroll() {
        #if CANCALL
        Task {
            let result =  await interactor.fetchTrending(.init(apiKey: apiKey, path: endPoints.trending, limit: 50, offset: currentCount))
            switch result {
            case .success(let success):
                await MainActor.run {
                    gifData.append(contentsOf: success)
                    currentCount += 50
                }
            case .failure(let failure):
                errorEvent.send(failure)
            }
        }
        #endif
    }
    
    func toggleSearchState() {
        searchState = searchState == .global ? .byId : .global
    }
}


