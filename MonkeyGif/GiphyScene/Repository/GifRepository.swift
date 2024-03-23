//
//  GifRepository.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import Foundation
import CoreData

protocol GifRepositoryProtocol {
    var controller: GifControllerProtocol { get }
    func save(_ gifData: [GifData]) async throws
    func fetchTrending(_ query: TrendingQuery) async -> GifDataResult
    func getGifById(_ query: GetByIdQuery) async -> GifDataResult
    func searchGif(_ query: SearchQuery)  async -> GifDataResult
}

struct GifRepository: GifRepositoryProtocol {
    
    let controller: GifControllerProtocol
    let urlSession: URLSession
    
    init(controller: GifControllerProtocol, urlSession: URLSession) {
        self.controller = controller
        self.urlSession = urlSession
    }
    
    func save(_ gifData: [GifData]) async throws {
        try await controller.save(gifData)
    }
    
    func fetchTrending(_ query: TrendingQuery) async -> GifDataResult{
        let trendingApi = TrendingApi(query: query)
        let result =  await trendingApi.fetch(session: urlSession)
        switch result {
        case .success(let data):
            let gifData = data.data.map { $0.toGifData() }
            return .success(gifData)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getGifById(_ query: GetByIdQuery) async -> GifDataResult {
        let getByIdApi = GetByIdApi(query: query)
        let result = await getByIdApi.fetch(session: urlSession)
        switch result {
        case .success(let data):
            let data = data.data.toGifData()
            return .success([data])
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func searchGif(_ query: SearchQuery)  async -> GifDataResult {
        let searchApi = SearchQueryApi(query: query)
        let result = await searchApi.fetch(session: urlSession)
        switch result {
        case .success(let data):
            let gifData = data.data.map { $0.toGifData() }
            return .success(gifData)
        case .failure(let error):
            return .failure(error)
        }
    }
}
