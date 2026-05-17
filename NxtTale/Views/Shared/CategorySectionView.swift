//
//  CategorySectionView.swift
//  NxtTale
//
//  Created by Vikram Kumar on 17/05/26.
//

import SwiftUI

struct CategorySectionView: View {
    let section: CategorySection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.name)
                .font(.title3.bold())
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(section.books) { book in
                        BookCardView(book: book)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
