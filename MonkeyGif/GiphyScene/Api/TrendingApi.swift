//
//  TrendingWorker.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 19/03/2024.
//

import Foundation

typealias GifySearchCallResult = Result<GiphySearchData, AppError>

struct TrendingApi: ApiWorkerProtocol {
    
    typealias Query = TrendingQuery
    typealias GifyResult = GiphySearchData
    
    let query: TrendingQuery
    
    init(query: TrendingQuery) {
        self.query = query
    }
}
