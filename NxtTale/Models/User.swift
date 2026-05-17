import Foundation

struct User: Codable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var birthdate: String?
    var profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName, lastName, username, email, birthdate, profilePhoto
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct ErrorResponse: Codable {
    let message: String?
}
