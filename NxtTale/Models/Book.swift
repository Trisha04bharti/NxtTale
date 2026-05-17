//
//  Book.swift
//  NxtTale
//
//  Created by Vikram Kumar on 16/05/26.
//
struct Book: Codable, Identifiable {
    var id: String
    var googleBookId: String?
    var title: String
    var authors: [String]
    var description: String?
    var coverImage: String?
    var publishedDate: String?
    var pageCount: Int?
    var averageRating: Double?
    var categories: [String]?      // ← add this

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case googleBookId, title, authors, description
        case coverImage, publishedDate, pageCount, averageRating, categories
    }

    var authorsText: String {
        authors.joined(separator: ", ")
    }
}
