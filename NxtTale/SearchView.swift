

import SwiftUI
import Lottie

struct SearchView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var bookVM = BookViewModel()
    @FocusState private var isSearchFocused: Bool

    var showLottie: Bool {
        bookVM.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Search Bar ──
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search by title or author...", text: $bookVM.searchQuery)
                        .autocapitalization(.none)
                        .focused($isSearchFocused)
                        .onChange(of: bookVM.searchQuery) { newValue in
                            if newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                                bookVM.searchResults = []
                            }
                        }
                        .onSubmit {
                            Task { await bookVM.search(token: authVM.token) }
                        }

                    if !bookVM.searchQuery.isEmpty {
                        Button {
                            bookVM.searchQuery  = ""
                            bookVM.searchResults = []
                            isSearchFocused     = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)

                // ── Content Area ──
                if showLottie {
                    // Lottie animation when nothing searched
                    VStack(spacing: 16) {
                        
                        Text("Search for your next book")
                            .font(.title3.bold())

                        Text("Find books by title, author, or genre")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        LottieView(animation: .named("search"))
                            .playing(loopMode: .loop)
                            .frame(width: 280, height: 280)

                  
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)

                } else if bookVM.isLoading {
                    // Loading spinner
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Searching...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)

                } else if bookVM.searchResults.isEmpty {
                    // No results found
                    VStack(spacing: 12) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No results for \"\(bookVM.searchQuery)\"")
                            .font(.headline)
                        Text("Try a different title or author name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)

                } else {
                    // Search results list
                    List(bookVM.searchResults) { book in
                        BookRowView(book: book)
                    }
                    .listStyle(.plain)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showLottie)
            .animation(.easeInOut(duration: 0.3), value: bookVM.isLoading)
            .navigationTitle("Search")
        }
    }
}
