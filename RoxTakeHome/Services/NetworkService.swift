//
//  NetworkService.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import Foundation


final class NetworkService: NetworkServiceProtocol {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    func fetch<T: Decodable>(from endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NewsError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NewsError.unknown
            }
            
            try validateResponse(httpResponse, data: data)
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NewsError.decodingError(error.localizedDescription)
            }
            
        } catch let error as NewsError {
            throw error
        } catch let error as URLError {
            throw mapURLError(error)
        } catch {
            throw NewsError.unknown
        }
    }
    
    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw NewsError.unauthorized
        case 429:
            throw NewsError.rateLimitExceeded
        case 400...499:
            let message = (try? decoder.decode(APIErrorResponse.self, from: data))?.message
                ?? "Client error: \(response.statusCode)"
            throw NewsError.apiError(message)
        case 500...599:
            throw NewsError.apiError("Server error: \(response.statusCode)")
        default:
            throw NewsError.unknown
        }
    }
    
    private func mapURLError(_ error: URLError) -> NewsError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkError("No internet connection")
        case .timedOut:
            return .networkError("Request timed out")
        case .cannotFindHost, .cannotConnectToHost:
            return .networkError("Cannot connect to server")
        default:
            return .networkError(error.localizedDescription)
        }
    }
}


private struct APIErrorResponse: Decodable {
    let status: String
    let code: String
    let message: String
}
