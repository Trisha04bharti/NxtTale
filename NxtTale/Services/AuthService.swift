import Foundation

enum APIError: Error, LocalizedError {
    case serverError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .serverError(let msg): return msg
        case .unknown: return "Something went wrong"
        }
    }
}

class AuthService {
    static let shared = AuthService()
    private let base = "http://localhost:5000/api"

    func signup(firstName: String, lastName: String, username: String,
                email: String, password: String) async throws -> AuthResponse {
        var req = URLRequest(url: URL(string: "\(base)/auth/signup")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: [
            "firstName": firstName, "lastName": lastName,
            "username": username, "email": email, "password": password
        ])
        let (data, _) = try await URLSession.shared.data(for: req)
        
        // Check for server error first
        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data),
           let message = errorResponse.message {
            throw APIError.serverError(message)
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }

    func login(identifier: String, password: String) async throws -> AuthResponse {
        var req = URLRequest(url: URL(string: "\(base)/auth/login")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: [
            "identifier": identifier, "password": password
        ])
        let (data, _) = try await URLSession.shared.data(for: req)
        
        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data),
           let message = errorResponse.message {
            throw APIError.serverError(message)
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }

    func updateProfile(token: String, birthdate: String?, photoBase64: String?) async throws -> User {
        var req = URLRequest(url: URL(string: "\(base)/user/profile")!)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        var body: [String: Any] = [:]
        if let b = birthdate { body["birthdate"] = b }
        if let p = photoBase64 { body["profilePhoto"] = p }
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(User.self, from: data)
    }
}
