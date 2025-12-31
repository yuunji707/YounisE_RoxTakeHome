//
//  ArticleCardView.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import SwiftUI


struct ArticleCardView: View {
    let article: Article
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            contentSection
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            CachedAsyncImage(url: article.urlToImage.flatMap { URL(string: $0) })
                .frame(height: 200)
                .clipped()
            
            favoriteButton
                .padding(12)
        }
    }
    
    private var favoriteButton: some View {
        Button {
            HapticManager.impact(.medium)
            onFavoriteToggle()
        } label: {
            Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                .font(.title3)
                .foregroundStyle(isFavorite ? Color.neonCyan : .white)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(article.source.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.neonCyan)
                    .lineLimit(1)
                
                Spacer()
                
                Text(article.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(article.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            if let description = article.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            if let author = article.author, !author.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .font(.caption)
                    Text(author)
                        .font(.caption)
                }
                .foregroundStyle(.tertiary)
                .lineLimit(1)
            }
        }
        .padding(16)
    }
}


struct CompactArticleCard: View {
    let article: Article
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CachedAsyncImage(url: article.urlToImage.flatMap { URL(string: $0) })
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(article.source.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.neonCyan)
                
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 0)
                
                HStack {
                    Text(article.formattedDate)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        HapticManager.impact(.medium)
                        onFavoriteToggle()
                    } label: {
                        Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                            .font(.caption)
                            .foregroundStyle(isFavorite ? Color.neonCyan : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}


struct ArticlePlaceholderGradient: View {
    var body: some View {
        LinearGradient(
            colors: [Color.neonPurple.opacity(0.3), Color.neonCyan.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "newspaper")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.5))
        )
    }
}
