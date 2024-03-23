//
//  MonkeyGifTests.swift
//  MonkeyGifTests
//
//  Created by Ruben Mimoun on 22/03/2024.
//

import XCTest
import Combine
@testable import MonkeyGif

final class MonkeyGifTests: XCTestCase {
    
    class APIMock<Query: ApiQueryProtocol>: ApiWorkerProtocol {
        typealias Query = Query
        var query: Query
        
        typealias GifyResult = GiphySearchData
        
        init(query: Query) {
            self.query = query
        }
        
    }
    
    class ControllerMock: GifControllerProtocol {
        var saved: Bool = false
        
        func save(_ gifData: [MonkeyGif.GifData]) async throws {
            saved = true
        }
    }
    
    class RepositoryMock: GifRepositoryProtocol {
        
        let controller:  GifControllerProtocol
        let resultData: [GifData] = .init(repeating: .init(imageId: .init(), url: "", isFavorite: false), count: 4)
        
        init(controller: GifControllerProtocol) {
            self.controller = controller
        }
        
        func save(_ gifData: [MonkeyGif.GifData]) async throws {
            try await controller.save(gifData)
        }
        
        func fetchTrending(_ query: MonkeyGif.TrendingQuery) async -> MonkeyGif.GifDataResult {
            return .success(resultData)
        }
        
        func getGifById(_ query: MonkeyGif.GetByIdQuery) async -> MonkeyGif.GifDataResult {
            return .success([resultData.first!])
        }
        
        func searchGif(_ query: MonkeyGif.SearchQuery) async -> MonkeyGif.GifDataResult {
            if query.q.isEmpty {
                return .success([])
            } else {
                return .success(resultData)
            }
        }
    }
    
    class InteractorMock: ApiInteractorProtocol {
        
        let repository:  GifRepositoryProtocol
        
        init(repository: GifRepositoryProtocol) {
            self.repository = repository
        }
        
        func save(_ gif: MonkeyGif.GifData) async throws {
            try await repository.save([gif])
        }
        
        func fetchTrending(_ query: MonkeyGif.TrendingQuery) async -> MonkeyGif.GifDataResult {
            return await repository.fetchTrending(query)
        }
        
        func getGifById(_ query: MonkeyGif.GetByIdQuery) async -> MonkeyGif.GifDataResult {
            return await repository.getGifById(query)
        }
        
        func searchGif(_ query: MonkeyGif.SearchQuery) async -> MonkeyGif.GifDataResult {
            return await repository.searchGif(query)
        }
    }
    
    var appViewController: AppViewController!
    var appControllerViewModel: AppViewControllerViewModel!
    var cancellables: Set<AnyCancellable>!
    
    
    override func setUp() {
        cancellables = Set<AnyCancellable>()
        let controller = ControllerMock()
        let repository = GifRepository(controller: controller, urlSession: .envSession)
        let interactor = InteractorMock(repository: repository)
        appControllerViewModel = .init(apiKey: "DcUNF908rOYRCIz5PneEqOJAL6g4LSNF", interactor: interactor)
    }
    
    override func tearDown() {
        appControllerViewModel = nil
        cancellables = nil
    }
    
    
    private func setupURLs() {
        func readJson(name: String) -> Data {
            let url = Bundle(for: Self.self).url(forResource: name, withExtension: "json")!
            return try! Data(contentsOf: url)
        }
    }
    
    @MainActor
    func testFetchingData() {
        let expectation = XCTestExpectation(description: "Async function completed")
        appViewController = .init(viewModel: appControllerViewModel)
        var result: [GifData] = []
        appControllerViewModel.$fetchState
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .idle:
                    break
                case .fetched(let data):
                    result = data
                    expectation.fulfill()
                case .failure(_):
                    break
                }
            }
            .store(in: &cancellables)
        appViewController.request()
        wait(for: [expectation], timeout: 10)
        XCTAssert(result.count == 2, "Result data is supposed to return 2 elements, not \(result.count)")
    }
    
    @MainActor
    func testSearchingData() {
        let expectation = XCTestExpectation(description: "Async function completed")
        appViewController = .init(viewModel: appControllerViewModel)
        var result: [GifData] = []
        appControllerViewModel.$fetchState
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .idle:
                    break
                case .fetched(let data):
                    result = data
                    expectation.fulfill()
                case .failure(_):
                    break
                }
            }
            .store(in: &cancellables)
        
        self.appControllerViewModel.searchText = "Food"

        wait(for: [expectation], timeout: 10)
        XCTAssert(result.count == 4, "Result data is supposed to return 4 elements not \(result.count)")
    }
    
    @MainActor
    func testSearchingDataEmptyQuery() {
        let expectation = XCTestExpectation(description: "Async function completed")
        appViewController = .init(viewModel: appControllerViewModel)
        let currentstate = appControllerViewModel.fetchState
        self.appControllerViewModel.searchText = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 2)
        XCTAssert(appControllerViewModel.fetchState == currentstate, "The state is not supposed to change when input is empty")
    }
    
    @MainActor
    func testSearchingById() {
        let expectation = XCTestExpectation(description: "Async function completed")
        appViewController = .init(viewModel: appControllerViewModel)
        appControllerViewModel.toggleSearchState()
        var currentstate = appControllerViewModel.fetchState
        var result: [GifData] = []
        appControllerViewModel.$fetchState
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .idle:
                    break
                case .fetched(let data):
                    result = data
                    expectation.fulfill()
                case .failure(_):
                    break
                }
            }
            .store(in: &cancellables)
        self.appControllerViewModel.searchText = "xT4uQulxzV39haRFjG"
        wait(for: [expectation], timeout: 2)
        XCTAssert(result.count == 1, "Search by id should return one element")
    }
    
    @MainActor
    func testSearchingByIdDataEmptyQuery() {
        let expectation = XCTestExpectation(description: "Async function completed")
        appViewController = .init(viewModel: appControllerViewModel)
        appControllerViewModel.toggleSearchState()
        var currentstate = appControllerViewModel.fetchState
        self.appControllerViewModel.searchText = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 2)
        XCTAssert(appControllerViewModel.fetchState == currentstate, "The state is not supposed to change when input is empty")
    }
    
}
