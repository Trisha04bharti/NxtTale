//
//  BookService.swift
//  NxtTale
//
//  Created by Vikram Kumar on 16/05/26.
//

import Foundation

class BookService {
    static let shared = BookService()
    private let base = "http://localhost:5000/api"

    func getFeed(token: String) async throws -> [Book] {
        var req = URLRequest(url: URL(string: "\(base)/books/feed")!)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode([Book].self, from: data)
    }

    func searchBooks(query: String, token: String) async throws -> [Book] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        var req = URLRequest(url: URL(string: "\(base)/books/search?q=\(encoded)")!)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode([Book].self, from: data)
    }
}
