//
//  RecentlyReadSectionView.swift
//  NxtTale
//
//  Created by Vikram Kumar on 17/05/26.
//

import SwiftUI

struct RecentlyReadSectionView: View {
    let books: [Book]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.orange)
                Text("Recently Read")
                    .font(.title3.bold())
                Spacer()
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(books) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            HStack(spacing: 10) {
                                AsyncImage(url: URL(string: book.coverImage ?? "")) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().scaledToFill()
                                    default:
                                        Color.gray.opacity(0.3)
                                            .overlay(Image(systemName: "book.closed")
                                                .foregroundColor(.gray))
                                    }
                                }
                                .frame(width: 56, height: 56)
                                .cornerRadius(8)
                                .clipped()

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(book.title)
                                        .font(.caption.bold())
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                        .frame(width: 100, alignment: .leading)
                                    Text(book.authorsText)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .frame(width: 100, alignment: .leading)
                                }
                            }
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
