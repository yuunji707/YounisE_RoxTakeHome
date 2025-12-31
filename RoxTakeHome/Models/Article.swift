//
//  Article.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//


import Foundation


struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}


struct Article: Codable, Identifiable, Equatable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    var id: String { url }
    
    
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    private static let isoFormatterNoFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var formattedDate: String {
        let date = Self.isoFormatter.date(from: publishedAt)
            ?? Self.isoFormatterNoFractional.date(from: publishedAt)
        
        guard let date else { return publishedAt }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return Self.relativeFormatter.localizedString(for: date, relativeTo: Date())
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return Self.displayFormatter.string(from: date)
        }
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.url == rhs.url
    }
}


struct Source: Codable, Equatable {
    let id: String?
    let name: String
}


struct FavoriteArticle: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let sourceName: String
    let author: String?
    let content: String?
    let savedAt: Date
    
    init(from article: Article) {
        self.id = article.id
        self.title = article.title
        self.description = article.description
        self.url = article.url
        self.urlToImage = article.urlToImage
        self.publishedAt = article.publishedAt
        self.sourceName = article.source.name
        self.author = article.author
        self.content = article.content
        self.savedAt = Date()
    }
    
    func toArticle() -> Article {
        Article(
            source: Source(id: nil, name: sourceName),
            author: author,
            title: title,
            description: description,
            url: url,
            urlToImage: urlToImage,
            publishedAt: publishedAt,
            content: content
        )
    }
}
