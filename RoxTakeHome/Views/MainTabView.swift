//
//  MainTabView.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import SwiftUI


struct MainTabView: View {
    @State private var selectedTab: Tab = .feed
    @State private var hasConfiguredAppearance = false
    @EnvironmentObject var newsFeedViewModel: NewsFeedViewModel
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    
    enum Tab: String, CaseIterable {
        case feed = "Feed"
        case favorites = "Saved"
        
        var icon: String {
            switch self {
            case .feed: return "newspaper"
            case .favorites: return "bookmark"
            }
        }
        
        var selectedIcon: String {
            icon + ".fill"
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NewsFeedView()
                .environmentObject(newsFeedViewModel)
                .environmentObject(favoritesViewModel)
                .tabItem {
                    Label(
                        Tab.feed.rawValue,
                        systemImage: selectedTab == .feed ? Tab.feed.selectedIcon : Tab.feed.icon
                    )
                }
                .tag(Tab.feed)
            
            FavoritesView()
                .environmentObject(favoritesViewModel)
                .tabItem {
                    Label(
                        Tab.favorites.rawValue,
                        systemImage: selectedTab == .favorites ? Tab.favorites.selectedIcon : Tab.favorites.icon
                    )
                }
                .tag(Tab.favorites)
        }
        .tint(.neonCyan)
        .onAppear {
            guard !hasConfiguredAppearance else { return }
            hasConfiguredAppearance = true
            
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
