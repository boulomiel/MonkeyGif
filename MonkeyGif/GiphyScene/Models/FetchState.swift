//
//  FetchState.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 22/03/2024.
//

import Foundation

enum FetchState<T>: Hashable {
    static func == (lhs: FetchState<T>, rhs: FetchState<T>) -> Bool {
        lhs.id ==  rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    case idle, fetched(T), failure(AppError)
    
    var id: Int {
        switch self {
        case .idle:
            return 0
        case .fetched:
            return 1
        case .failure:
            return 2
        }
    }
}
