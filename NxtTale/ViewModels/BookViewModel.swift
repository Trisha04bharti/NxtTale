//
//  BookViewModel.swift
//  NxtTale
//
//  Created by Vikram Kumar on 16/05/26.
//
import SwiftUI
import Combine

@MainActor
class BookViewModel: ObservableObject {
    @Published var feedBooks: [Book] = []
    @Published var searchResults: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var searchQuery = ""

    func loadFeed(token: String) async {
        isLoading = true
        do {
            feedBooks = try await BookService.shared.getFeed(token: token)
        } catch {
            errorMessage = error.localizedDescription
            print("FEED ERROR: \(error)")
        }
        isLoading = false
    }

    func search(token: String) async {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        isLoading = true
        do {
            searchResults = try await BookService.shared.searchBooks(
                query: searchQuery, token: token)
        } catch {
            errorMessage = error.localizedDescription
            print("SEARCH ERROR: \(error)")
        }
        isLoading = false
    }
}
