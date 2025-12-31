//
//  FavoritesRepository.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//
import Foundation
import Combine


final class FavoritesRepository: FavoritesRepositoryProtocol, ObservableObject {
    
    private let persistenceService: PersistenceServiceProtocol
    @Published private(set) var favorites: [FavoriteArticle] = []
    
    init(persistenceService: PersistenceServiceProtocol) {
        self.persistenceService = persistenceService
        loadFavoritesFromDisk()
    }
    
    
    func addFavorite(_ article: Article) throws {
        guard !isFavorite(article) else { return }
        
        let favoriteArticle = FavoriteArticle(from: article)
        favorites.insert(favoriteArticle, at: 0)
        
        try saveFavoritesToDisk()
    }
    
    func removeFavorite(_ article: Article) throws {
        favorites.removeAll { $0.id == article.id }
        try saveFavoritesToDisk()
    }
    
    func isFavorite(_ article: Article) -> Bool {
        favorites.contains { $0.id == article.id }
    }
    
    
    private func loadFavoritesFromDisk() {
        do {
            favorites = try persistenceService.load(forKey: PersistenceKeys.favorites)
        } catch {
            favorites = []
        }
    }
    
    private func saveFavoritesToDisk() throws {
        try persistenceService.save(favorites, forKey: PersistenceKeys.favorites)
    }
}
