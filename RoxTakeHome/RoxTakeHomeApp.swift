//
//  RoxTakeHomeApp.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import SwiftUI

@main
struct RoxTakeHomeApp: App {
    @StateObject private var dependencies = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dependencies.newsFeedViewModel)
                .environmentObject(dependencies.favoritesViewModel)
                .environmentObject(dependencies.favoritesRepository)
        }
    }
}

@MainActor
final class DependencyContainer: ObservableObject {
    let favoritesRepository: FavoritesRepository
    let newsFeedViewModel: NewsFeedViewModel
    let favoritesViewModel: FavoritesViewModel
    
    init() {
        let networkService = NetworkService()
        let persistenceService = PersistenceService()
        let newsRepository = NewsRepository(networkService: networkService)
        
        self.favoritesRepository = FavoritesRepository(persistenceService: persistenceService)
        
        self.newsFeedViewModel = NewsFeedViewModel(
            newsRepository: newsRepository,
            favoritesRepository: favoritesRepository
        )
        self.favoritesViewModel = FavoritesViewModel(
            favoritesRepository: favoritesRepository
        )
    }
}
