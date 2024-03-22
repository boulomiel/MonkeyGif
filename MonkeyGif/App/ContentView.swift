//
//  ContentView.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 19/03/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    let apiKey: String
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        AppRepresentable(apiKey: apiKey)
            .ignoresSafeArea()
            .preferredColorScheme(.dark)
    }
}

struct AppRepresentable: UIViewControllerRepresentable {
    
    let apiKey: String
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewModel: AppViewControllerViewModel = .init(apiKey: apiKey, interactor: .init(repository: .init(controller: .init(controller: .shared))))
        let appController =  AppViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: appController)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

#Preview {
    let reader = PlistReader(keyList: .appKeys)
    let appKeys: AppKeys = reader.read()
    return ContentView(apiKey: appKeys.giphyApi)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
