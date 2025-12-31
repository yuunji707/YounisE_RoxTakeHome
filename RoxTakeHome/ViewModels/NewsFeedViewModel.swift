//
//  NewsFeedViewModel.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import Foundation
import Combine


@MainActor
final class NewsFeedViewModel: ObservableObject {
    
    @Published private(set) var articles: [Article] = []
    @Published private(set) var viewState: ViewState<[Article]> = .idle
    @Published var selectedCategory: NewsCategory? = nil
    @Published var searchQuery: String = ""
    @Published private(set) var hasMorePages: Bool = true
    @Published private(set) var isLoadingMore: Bool = false
    
    private let newsRepository: NewsRepositoryProtocol
    private let favoritesRepository: FavoritesRepository
    private var currentPage: Int = 1
    private var totalResults: Int = 0
    private var cancellables = Set<AnyCancellable>()
    private let pageSize = APIConfig.defaultPageSize
    
    init(
        newsRepository: NewsRepositoryProtocol,
        favoritesRepository: FavoritesRepository
    ) {
        self.newsRepository = newsRepository
        self.favoritesRepository = favoritesRepository
        setupBindings()
    }
    
    func loadArticles() async {
        viewState = .loading
        currentPage = 1
        articles = []
        await fetchArticles()
    }
    
    func loadMoreArticles() async {
        guard !isLoadingMore, hasMorePages else { return }
        
        isLoadingMore = true
        currentPage += 1
        await fetchArticles(isLoadingMore: true)
        isLoadingMore = false
    }
    
    func refresh() async {
        await loadArticles()
    }
    
    func toggleFavorite(_ article: Article) {
        do {
            if favoritesRepository.isFavorite(article) {
                try favoritesRepository.removeFavorite(article)
            } else {
                try favoritesRepository.addFavorite(article)
            }
            objectWillChange.send()
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
    }
    
    func isFavorite(_ article: Article) -> Bool {
        favoritesRepository.isFavorite(article)
    }
    
    func selectCategory(_ category: NewsCategory?) {
        guard selectedCategory != category else { return }
        selectedCategory = category
    }
    
    private func setupBindings() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.loadArticles()
                }
            }
            .store(in: &cancellables)
        
        $selectedCategory
            .dropFirst()
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.loadArticles()
                }
            }
            .store(in: &cancellables)
        
        favoritesRepository.$favorites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func fetchArticles(isLoadingMore: Bool = false) async {
        do {
            let result = try await newsRepository.fetchTopHeadlines(
                category: selectedCategory,
                query: searchQuery.isEmpty ? nil : searchQuery,
                page: currentPage,
                pageSize: pageSize
            )
            
            totalResults = result.totalResults
            
            if isLoadingMore {
                articles.append(contentsOf: result.articles)
            } else {
                articles = result.articles
            }
            
            hasMorePages = currentPage * pageSize < totalResults
            viewState = .loaded(articles)
            
        } catch let error as NewsError {
            if !isLoadingMore {
                viewState = .error(error)
            }
        } catch {
            if !isLoadingMore {
                viewState = .error(.unknown)
            }
        }
    }
}
