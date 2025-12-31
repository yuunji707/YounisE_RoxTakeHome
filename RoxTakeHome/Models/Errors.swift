//
//  Errors.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import Foundation


enum NewsError: Error, LocalizedError, Equatable {
    case networkError(String)
    case decodingError(String)
    case invalidURL
    case noData
    case apiError(String)
    case rateLimitExceeded
    case unauthorized
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError(let message):
            return "Data Error: \(message)"
        case .invalidURL:
            return "Invalid URL configuration"
        case .noData:
            return "No data received from server"
        case .apiError(let message):
            return "API Error: \(message)"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .unauthorized:
            return "Invalid API key. Please check your configuration."
        case .unknown:
            return "An unexpected error occurred"
        }
    }
    
    var recoverySuggestion: String {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .decodingError:
            return "The data format has changed. Please update the app."
        case .invalidURL:
            return "Please contact support."
        case .noData:
            return "Try refreshing or changing your search criteria."
        case .apiError:
            return "Please try again later."
        case .rateLimitExceeded:
            return "Wait a moment and try again."
        case .unauthorized:
            return "Verify your API key is correct."
        case .unknown:
            return "Please try again or restart the app."
        }
    }
    
    var icon: String {
        switch self {
        case .networkError:
            return "wifi.slash"
        case .decodingError, .invalidURL:
            return "exclamationmark.triangle"
        case .noData:
            return "doc.text.magnifyingglass"
        case .apiError, .rateLimitExceeded:
            return "clock.badge.exclamationmark"
        case .unauthorized:
            return "key.slash"
        case .unknown:
            return "questionmark.circle"
        }
    }
}


enum PersistenceError: Error, LocalizedError {
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case encodingFailed
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let message):
            return "Failed to save: \(message)"
        case .loadFailed(let message):
            return "Failed to load: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete: \(message)"
        case .encodingFailed:
            return "Failed to encode data"
        case .decodingFailed:
            return "Failed to decode data"
        }
    }
}
