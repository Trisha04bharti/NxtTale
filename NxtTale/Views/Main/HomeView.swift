import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var bookVM = BookViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if bookVM.isLoading && bookVM.feedBooks.isEmpty {
                    ProgressView("Loading books...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if bookVM.feedBooks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No books found")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(bookVM.feedBooks) { book in
                        BookRowView(book: book)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Hello, \(authVM.user?.firstName ?? "") 👋")
            .task {
                await bookVM.loadFeed(token: authVM.token)
            }
            .refreshable {
                await bookVM.loadFeed(token: authVM.token)
            }
        }
    }
}
