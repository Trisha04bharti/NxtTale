//
//  RecommendService.swift
//  NxtTale
//
//  Created by Vikram Kumar on 17/05/26.
//

import Foundation

class RecommendService {
    static let shared = RecommendService()
    private let base = "http://localhost:5000/api"

    func getRecommendations(token: String) async throws -> RecommendResponse {
        var req = URLRequest(url: URL(string: "\(base)/recommend")!)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(RecommendResponse.self, from: data)
    }

    func trackActivity(token: String, bookId: String, googleBookId: String?,
                       timeSpent: Int, categories: [String], authors: [String]) async {
        guard let url = URL(string: "\(base)/activity/track") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        var body: [String: Any] = [
            "bookId": bookId,
            "timeSpent": timeSpent,
            "categories": categories,
            "authors": authors,
            "action": "view"
        ]
        if let gid = googleBookId { body["googleBookId"] = gid }
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        try? await URLSession.shared.data(for: req)
    }
}
