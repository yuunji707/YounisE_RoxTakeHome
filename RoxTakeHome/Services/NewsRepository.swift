//
//  NewsRepository.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import Foundation


final class NewsRepository: NewsRepositoryProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchTopHeadlines(
        category: NewsCategory?,
        query: String?,
        page: Int,
        pageSize: Int
    ) async throws -> (articles: [Article], totalResults: Int) {
        let endpoint = APIEndpoint.topHeadlines(
            country: APIConfig.defaultCountry,
            category: category,
            query: query,
            page: page,
            pageSize: pageSize
        )
        
        let response: NewsAPIResponse = try await networkService.fetch(from: endpoint)
        
        let validArticles = response.articles.filter { article in
            !article.title.contains("[Removed]")
        }
        
        return (articles: validArticles, totalResults: response.totalResults)
    }
}
