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

struct RecommendResponse: Codable {
    let recommendations: [Book]
    let categories: [CategorySection]
    let reason: String?
}
