//
//  FavoritesViewModel.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import Foundation
import Combine


@MainActor
final class FavoritesViewModel: ObservableObject {
    
    @Published var favorites: [FavoriteArticle] = []
    @Published var sortOrder: SortOrder = .newestFirst
    
    private let favoritesRepository: FavoritesRepository
    
    enum SortOrder: String, CaseIterable, Identifiable {
        case newestFirst = "Newest Saved"
        case oldestFirst = "Oldest Saved"
        case titleAZ = "Title A-Z"
        case titleZA = "Title Z-A"
        
        var id: String { rawValue }
    }
    
    var sortedFavorites: [FavoriteArticle] {
        switch sortOrder {
        case .newestFirst:
            return favorites.sorted { $0.savedAt > $1.savedAt }
        case .oldestFirst:
            return favorites.sorted { $0.savedAt < $1.savedAt }
        case .titleAZ:
            return favorites.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .titleZA:
            return favorites.sorted { $0.title.lowercased() > $1.title.lowercased() }
        }
    }
    
    var isEmpty: Bool {
        favorites.isEmpty
    }
    
    init(favoritesRepository: FavoritesRepository) {
        self.favoritesRepository = favoritesRepository
        self.favorites = favoritesRepository.favorites
        
        favoritesRepository.$favorites
            .receive(on: RunLoop.main)
            .assign(to: &$favorites)
    }
    
    func removeFavorite(_ favoriteArticle: FavoriteArticle) {
        do {
            try favoritesRepository.removeFavorite(favoriteArticle.toArticle())
        } catch {
            print("Failed to remove favorite: \(error)")
        }
    }
    
    func removeFavorite(at offsets: IndexSet) {
        for index in offsets {
            removeFavorite(sortedFavorites[index])
        }
    }
    
    func isFavorite(_ article: Article) -> Bool {
        favoritesRepository.isFavorite(article)
    }
}
