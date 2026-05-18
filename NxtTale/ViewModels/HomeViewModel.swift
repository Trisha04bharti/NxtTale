//
//  HomeViewModel.swift
//  NxtTale
//
//  Created by Vikram Kumar on 17/05/26.
//
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recommendations: [Book]      = []
    @Published var categories: [CategorySection] = []
    @Published var feedBooks: [Book]            = []
    @Published var recentlyRead: [Book]         = []
    @Published var similarSections: [SimilarSection] = []
    @Published var recommendReason: String?
    @Published var isLoading = false

    func loadAll(token: String) async {
        isLoading = true
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadFeed(token: token) }
            group.addTask { await self.loadRecommendations(token: token) }
        }
        isLoading = false
    }

    private func loadFeed(token: String) async {
        do {
            feedBooks = try await BookService.shared.getFeed(token: token)
        } catch {
            print("FEED ERROR: \(error)")
        }
    }

    private func loadRecommendations(token: String) async {
        do {
            let res      = try await RecommendService.shared.getRecommendations(token: token)
            recommendations  = res.recommendations
            categories       = res.categories
            recentlyRead     = res.recentlyRead
            similarSections  = res.similarSections
            recommendReason  = res.reason
        } catch {
            print("RECOMMEND ERROR: \(error)")
        }
    }
}
