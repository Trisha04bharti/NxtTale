//
//  SimilarBooksSectionView.swift
//  NxtTale
//
//  Created by Vikram Kumar on 17/05/26.
//

import SwiftUI

struct SimilarBooksSectionView: View {
    let section: SimilarSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header with source book thumbnail
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: section.sourceBook.coverImage ?? "")) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 36, height: 36)
                .cornerRadius(6)
                .clipped()

                VStack(alignment: .leading, spacing: 2) {
                    Text("Because you read")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(section.sourceBook.title)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                }

                Spacer()

                // Genre badge
                Text(section.genre)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.15))
                    .foregroundColor(.purple)
                    .cornerRadius(20)
            }
            .padding(.horizontal)

            // Similar books horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(section.books) { book in
                        BookCardView(book: book)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.05))
        )
        .padding(.horizontal, 8)
    }
}
