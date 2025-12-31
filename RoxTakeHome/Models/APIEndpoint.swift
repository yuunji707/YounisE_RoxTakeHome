//
//  APIEndpoint.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import Foundation


enum APIConfig {
    static let baseURL = "https://newsapi.org/v2"
    static let apiKey = "5ae0303ff53d43509557ae81a1ae21c2"
    static let defaultCountry = "us"
    static let defaultPageSize = 20
}


enum APIEndpoint {
    case topHeadlines(
        country: String = APIConfig.defaultCountry,
        category: NewsCategory? = nil,
        query: String? = nil,
        page: Int = 1,
        pageSize: Int = APIConfig.defaultPageSize
    )
    
    var url: URL? {
        var components = URLComponents(string: APIConfig.baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
    
    private var path: String {
        switch self {
        case .topHeadlines:
            return "/top-headlines"
        }
    }
    
    private var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: APIConfig.apiKey)
        ]
        
        switch self {
        case .topHeadlines(let country, let category, let query, let page, let pageSize):
            items.append(URLQueryItem(name: "country", value: country))
            
            if let category = category {
                items.append(URLQueryItem(name: "category", value: category.rawValue))
            }
            
            if let query = query, !query.isEmpty {
                items.append(URLQueryItem(name: "q", value: query))
            }
            
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "pageSize", value: String(pageSize)))
        }
        
        return items
    }
}
