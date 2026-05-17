import SwiftUI

struct SearchView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var bookVM = BookViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by title or author...", text: $bookVM.searchQuery)
                        .autocapitalization(.none)
                        .onSubmit {
                            Task { await bookVM.search(token: authVM.token) }
                        }
                    if !bookVM.searchQuery.isEmpty {
                        Button {
                            bookVM.searchQuery = ""
                            bookVM.searchResults = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                // Results
                if bookVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if bookVM.searchResults.isEmpty && !bookVM.searchQuery.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No results for \"\(bookVM.searchQuery)\"")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if bookVM.searchResults.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Search for books by title or author")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(bookVM.searchResults) { book in
                        BookRowView(book: book)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search")
            .toolbar {
                if bookVM.isLoading {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ProgressView()
                    }
                }
            }
        }
    }
}
