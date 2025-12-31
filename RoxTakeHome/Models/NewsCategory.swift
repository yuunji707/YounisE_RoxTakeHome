//
//  NewsCategory.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import Foundation


enum NewsCategory: String, CaseIterable, Identifiable {
    case general
    case business
    case entertainment
    case health
    case science
    case sports
    case technology
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .general: return "newspaper"
        case .business: return "chart.line.uptrend.xyaxis"
        case .entertainment: return "film"
        case .health: return "heart"
        case .science: return "atom"
        case .sports: return "sportscourt"
        case .technology: return "desktopcomputer"
        }
    }
    
    var accentColor: String {
        switch self {
        case .general: return "CategoryGeneral"
        case .business: return "CategoryBusiness"
        case .entertainment: return "CategoryEntertainment"
        case .health: return "CategoryHealth"
        case .science: return "CategoryScience"
        case .sports: return "CategorySports"
        case .technology: return "CategoryTechnology"
        }
    }
}


enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(NewsError)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
