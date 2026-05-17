import SwiftUI

// ── Meta Info Widget ──
struct MetaItem: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(value)
                .font(.subheadline.bold())
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// ── Book Detail View ──
struct BookDetailView: View {
    let book: Book
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var appearedAt: Date = Date()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // ── Hero Cover ──
                AsyncImage(url: URL(string: book.coverImage ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure(_):
                        Color.gray.opacity(0.3)
                            .overlay(
                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            )
                    case .empty:
                        Color.gray.opacity(0.2)
                            .overlay(ProgressView())
                    @unknown default:
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 380)
                .clipped()

                // ── Content ──
                VStack(alignment: .leading, spacing: 20) {

                    // Title + Author
                    VStack(alignment: .leading, spacing: 6) {
                        Text(book.title)
                            .font(.title2.bold())
                            .fixedSize(horizontal: false, vertical: true)

                        if !book.authors.isEmpty {
                            Text(book.authorsText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    // Meta Row
                    HStack(spacing: 24) {
                        if let rating = book.averageRating, rating > 0 {
                            MetaItem(
                                icon: "star.fill",
                                color: .yellow,
                                label: "Rating",
                                value: String(format: "%.1f", rating)
                            )
                        }
                        if let pages = book.pageCount, pages > 0 {
                            MetaItem(
                                icon: "doc.text",
                                color: .blue,
                                label: "Pages",
                                value: "\(pages)"
                            )
                        }
                        if let date = book.publishedDate, !date.isEmpty {
                            MetaItem(
                                icon: "calendar",
                                color: .green,
                                label: "Year",
                                value: String(date.prefix(4))
                            )
                        }
                    }

                    Divider()

                    // Categories
                    if let categories = book.categories, !categories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(categories, id: \.self) { cat in
                                    Text(cat)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }

                    // Description
                    if let desc = book.description, !desc.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About this book")
                                .font(.headline)
                            Text(desc)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            appearedAt = Date()
        }
        .onDisappear {
            let seconds = Int(Date().timeIntervalSince(appearedAt))
            guard seconds > 2 else { return }
            Task {
                await RecommendService.shared.trackActivity(
                    token: authVM.token,
                    bookId: book.id,
                    googleBookId: book.googleBookId,
                    timeSpent: seconds,
                    categories: book.categories ?? [],
                    authors: book.authors
                )
            }
        }
    }
}
