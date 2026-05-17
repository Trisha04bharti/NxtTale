import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var token: String = ""
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    @Published var isLoading = false

    func signup(firstName: String, lastName: String, username: String,
                email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            let res = try await AuthService.shared.signup(
                firstName: firstName,
                lastName: lastName,
                username: username,
                email: email,
                password: password
            )
            token = res.token
            user = res.user
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
            print("SIGNUP ERROR: \(error)") // ← shows exact error in Xcode console
        }
        isLoading = false
    }

    func login(identifier: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            let res = try await AuthService.shared.login(
                identifier: identifier,
                password: password
            )
            token = res.token
            user = res.user
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
            print("LOGIN ERROR: \(error)") // ← shows exact error in Xcode console
        }
        isLoading = false
    }

    func logout() {
        user = nil
        token = ""
        isLoggedIn = false
    }
}
