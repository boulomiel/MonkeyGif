//
//  ApiInteractor.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import Foundation

struct ApiInteractor {
    
    private let repository: GifRepository
    
    init(repository: GifRepository = .init(controller: .init(controller: .shared))) {
        self.repository = repository
    }

    func save(_ gif: GifData) async throws {
        try await repository.save([gif])
    }
    
    func fetchTrending(_ query: TrendingQuery) async -> GifDataResult{
        await repository.fetchTrending(query)
    }
    
    func getGifById(_ query: GetByIdQuery) async -> GifDataResult {
        await repository.getGifById(query)
    }
    
    func searchGif(_ query: SearchQuery)  async -> GifDataResult{
        await repository.searchGif(query)
    }
}
