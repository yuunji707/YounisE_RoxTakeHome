//
//  NewsDetailViewModel.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import Foundation
import Combine


@MainActor
final class NewsDetailViewModel: ObservableObject {
    
    @Published private(set) var article: Article
    @Published private(set) var isFavorite: Bool
    
    private let favoritesRepository: FavoritesRepository
    private var cancellables = Set<AnyCancellable>()
    
    var articleURL: URL? {
        URL(string: article.url)
    }
    
    var shareText: String {
        "\(article.title) - \(article.url)"
    }
    
    init(article: Article, favoritesRepository: FavoritesRepository) {
        self.article = article
        self.favoritesRepository = favoritesRepository
        self.isFavorite = favoritesRepository.isFavorite(article)
        
        favoritesRepository.$favorites
            .receive(on: DispatchQueue.main)
            .map { [weak favoritesRepository, article] _ in
                favoritesRepository?.isFavorite(article) ?? false
            }
            .assign(to: &$isFavorite)
    }
    
    func toggleFavorite() {
        do {
            if isFavorite {
                try favoritesRepository.removeFavorite(article)
            } else {
                try favoritesRepository.addFavorite(article)
            }
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
    }
}
