//
//  BookRowView.swift


import SwiftUI

struct BookRowView: View {
    let book: Book

    var body: some View {
        NavigationLink(destination: BookDetailView(book: book)) {
            HStack(spacing: 12) {
                // Cover Image
                AsyncImage(url: URL(string: book.coverImage ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure(_):
                        Color.gray.opacity(0.3)
                            .overlay(Image(systemName: "book.closed")
                                .foregroundColor(.gray))
                    case .empty:
                        Color.gray.opacity(0.2)
                            .overlay(ProgressView())
                    @unknown default:
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()

                // Book Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(book.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    if !book.authors.isEmpty {
                        Text(book.authorsText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    if let rating = book.averageRating, rating > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 6)
        }
    }
}
