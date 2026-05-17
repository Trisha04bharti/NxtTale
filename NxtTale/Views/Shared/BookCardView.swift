//
//  BookCardView.swift
//  NxtTale
//
//  Created by Vikram Kumar on 17/05/26.
//

import SwiftUI

struct BookCardView: View {
    let book: Book

    var body: some View {
        NavigationLink(destination: BookDetailView(book: book)) {
            VStack(alignment: .leading, spacing: 6) {
                AsyncImage(url: URL(string: book.coverImage ?? "")) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure(_):
                        Color.gray.opacity(0.3)
                            .overlay(Image(systemName: "book.closed.fill")
                                .foregroundColor(.gray))
                    default:
                        Color.gray.opacity(0.2).overlay(ProgressView())
                    }
                }
                .frame(width: 110, height: 160)
                .cornerRadius(10)
                .clipped()
                .shadow(radius: 4)

                Text(book.title)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(width: 110, alignment: .leading)

                Text(book.authorsText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(width: 110, alignment: .leading)
            }
        }
    }
}
