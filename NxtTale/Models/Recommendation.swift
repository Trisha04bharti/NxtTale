//
//  Recommendation.swift
//  NxtTale
//
//  Created by Vikram Kumar on 17/05/26.
//

import Foundation

struct CategorySection: Codable, Identifiable {
    var id: String { name }
    let name: String
    let books: [Book]
}

struct SourceBook: Codable {
    let id: String
    let title: String
    let coverImage: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, coverImage
    }
}

struct SimilarSection: Codable, Identifiable {
    var id: String { sourceBook.id }
    let sourceBook: SourceBook
    let genre: String
    let books: [Book]
}

struct RecommendResponse: Codable {
    let recommendations: [Book]
    let categories: [CategorySection]
    let recentlyRead: [Book]
    let similarSections: [SimilarSection]
    let reason: String?
}
