//
//  Protocols.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import Foundation


protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from endpoint: APIEndpoint) async throws -> T
}


protocol PersistenceServiceProtocol {
    func save<T: Encodable>(_ data: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T
    func delete(forKey key: String) throws
    func exists(forKey key: String) -> Bool
}


protocol NewsRepositoryProtocol {
    func fetchTopHeadlines(
        category: NewsCategory?,
        query: String?,
        page: Int,
        pageSize: Int
    ) async throws -> (articles: [Article], totalResults: Int)
}


protocol FavoritesRepositoryProtocol {
    var favorites: [FavoriteArticle] { get }
    func addFavorite(_ article: Article) throws
    func removeFavorite(_ article: Article) throws
    func isFavorite(_ article: Article) -> Bool
}
