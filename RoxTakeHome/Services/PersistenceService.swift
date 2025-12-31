//
//  PersistenceService.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//



import Foundation


final class PersistenceService: PersistenceServiceProtocol {
    
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func save<T: Encodable>(_ data: T, forKey key: String) throws {
        let url = try fileURL(forKey: key)
        
        do {
            let encodedData = try encoder.encode(data)
            try encodedData.write(to: url, options: [.atomic, .completeFileProtection])
        } catch is EncodingError {
            throw PersistenceError.encodingFailed
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }
    
    func load<T: Decodable>(forKey key: String) throws -> T {
        let url = try fileURL(forKey: key)
        
        guard fileManager.fileExists(atPath: url.path) else {
            throw PersistenceError.loadFailed("File does not exist")
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch is DecodingError {
            throw PersistenceError.decodingFailed
        } catch {
            throw PersistenceError.loadFailed(error.localizedDescription)
        }
    }
    
    func delete(forKey key: String) throws {
        let url = try fileURL(forKey: key)
        
        guard fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw PersistenceError.deleteFailed(error.localizedDescription)
        }
    }
    
    func exists(forKey key: String) -> Bool {
        guard let url = try? fileURL(forKey: key) else { return false }
        return fileManager.fileExists(atPath: url.path)
    }
    
    private func fileURL(forKey key: String) throws -> URL {
        guard let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw PersistenceError.saveFailed("Could not access documents directory")
        }
        
        return documentsDirectory.appendingPathComponent("\(key).json")
    }
}


enum PersistenceKeys {
    static let favorites = "favorites"
}
