//
//  NewsFeedView.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import SwiftUI


struct NewsFeedView: View {
    @EnvironmentObject var viewModel: NewsFeedViewModel
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @EnvironmentObject var favoritesRepository: FavoritesRepository
    @State private var showingCategoryPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryFilterSection
                contentView
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search headlines..."
            )
            .refreshable {
                await viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCategoryPicker.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundStyle(viewModel.selectedCategory != nil ? Color.neonCyan : .primary)
                    }
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerSheet(selectedCategory: $viewModel.selectedCategory)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .task {
            if case .idle = viewModel.viewState {
                await viewModel.loadArticles()
            }
        }
    }
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: "All",
                    icon: "globe",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    HapticManager.impact(.light)
                    viewModel.selectCategory(nil)
                }
                
                ForEach(NewsCategory.allCases) { category in
                    CategoryChip(
                        title: category.displayName,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        HapticManager.impact(.light)
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .idle:
            Color.clear
            
        case .loading:
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { _ in
                        SkeletonArticleCard()
                    }
                }
                .padding()
            }
            
        case .loaded(let articles):
            if articles.isEmpty {
                EmptyStateView(
                    icon: "newspaper",
                    title: "No Articles Found",
                    message: viewModel.searchQuery.isEmpty
                        ? "There are no articles available for this category."
                        : "Try adjusting your search terms."
                )
            } else {
                articlesList(articles)
            }
            
        case .error(let error):
            ErrorView(error: error) {
                Task {
                    await viewModel.loadArticles()
                }
            }
        }
    }
    
    private func articlesList(_ articles: [Article]) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(articles) { article in
                    NavigationLink(destination: newsDetailView(for: article)) {
                        ArticleCardView(
                            article: article,
                            isFavorite: viewModel.isFavorite(article)
                        ) {
                            viewModel.toggleFavorite(article)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                if viewModel.hasMorePages {
                    loadMoreSection
                }
            }
            .padding()
        }
    }
    
    private var loadMoreSection: some View {
        Group {
            if viewModel.isLoadingMore {
                HStack(spacing: 12) {
                    ProgressView()
                        .tint(Color.neonCyan)
                    Text("Loading more...")
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        Task {
                            await viewModel.loadMoreArticles()
                        }
                    }
            }
        }
    }
    
    private func newsDetailView(for article: Article) -> some View {
        let detailViewModel = NewsDetailViewModel(
            article: article,
            favoritesRepository: favoritesRepository
        )
        return NewsDetailView(viewModel: detailViewModel)
            .environmentObject(favoritesViewModel)
            .environmentObject(favoritesRepository)
    }
}


struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? Color.neonCyan.opacity(0.2)
                    : Color(uiColor: .secondarySystemBackground)
            )
            .foregroundStyle(isSelected ? Color.neonCyan : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.neonCyan : .clear, lineWidth: 1.5)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}


struct CategoryPickerSheet: View {
    @Binding var selectedCategory: NewsCategory?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    categoryRow(category: nil, title: "All Categories", icon: "globe")
                }
                
                Section("Categories") {
                    ForEach(NewsCategory.allCases) { category in
                        categoryRow(
                            category: category,
                            title: category.displayName,
                            icon: category.icon
                        )
                    }
                }
            }
            .navigationTitle("Filter by Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func categoryRow(category: NewsCategory?, title: String, icon: String) -> some View {
        Button {
            HapticManager.impact(.light)
            selectedCategory = category
            dismiss()
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(category == nil ? Color.neonCyan : .primary)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if selectedCategory == category {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.neonCyan)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

