//
//  FavoritesView.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import SwiftUI


struct FavoritesView: View {
    @EnvironmentObject var viewModel: FavoritesViewModel
    @EnvironmentObject var favoritesRepository: FavoritesRepository
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favorites.isEmpty {
                    emptyStateView
                } else {
                    favoritesListView
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !viewModel.favorites.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        sortButton
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.neonCyan.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "bookmark")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.neonCyan)
            }
            
            VStack(spacing: 8) {
                Text("No Saved Articles")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Articles you save will appear here.\nTap the bookmark icon to save articles.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var favoritesListView: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.favorites.count) Article\(viewModel.favorites.count == 1 ? "" : "s")")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("Sorted by \(viewModel.sortOrder.rawValue.lowercased())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            
            Section {
                ForEach(viewModel.sortedFavorites) { favorite in
                    ZStack {
                        NavigationLink(destination: newsDetailView(for: favorite)) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        FavoriteRowView(article: favorite)
                    }
                }
                .onDelete(perform: viewModel.removeFavorite)
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: viewModel.favorites.count)
    }
    
    private var sortButton: some View {
        Menu {
            ForEach(FavoritesViewModel.SortOrder.allCases) { order in
                Button {
                    viewModel.sortOrder = order
                } label: {
                    HStack {
                        Text(order.rawValue)
                        if viewModel.sortOrder == order {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.body)
        }
    }
    
    private func newsDetailView(for favorite: FavoriteArticle) -> some View {
        let detailViewModel = NewsDetailViewModel(
            article: favorite.toArticle(),
            favoritesRepository: favoritesRepository
        )
        return NewsDetailView(viewModel: detailViewModel)
            .environmentObject(viewModel)
            .environmentObject(favoritesRepository)
    }
}


struct FavoriteRowView: View {
    let article: FavoriteArticle
    
    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CachedAsyncImage(url: article.urlToImage.flatMap { URL(string: $0) })
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(article.sourceName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.neonCyan)
                
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 4) {
                    Image(systemName: "bookmark.fill")
                        .font(.caption2)
                    Text("Saved \(Self.relativeDateFormatter.localizedString(for: article.savedAt, relativeTo: Date()))")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
