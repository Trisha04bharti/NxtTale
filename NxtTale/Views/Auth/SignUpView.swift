import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var vm: AuthViewModel
    @State private var firstName = ""
    @State private var lastName  = ""
    @State private var username  = ""
    @State private var email     = ""
    @State private var password  = ""
    @State private var showLogin = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 40)

                    Group {
                        HStack(spacing: 12) {
                            TextField("First Name", text: $firstName)
                                .textFieldStyle(.roundedBorder)
                            TextField("Last Name", text: $lastName)
                                .textFieldStyle(.roundedBorder)
                        }
                        TextField("Username", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }

                    if !vm.errorMessage.isEmpty {
                        Text(vm.errorMessage).foregroundColor(.red).font(.caption)
                    }

                    Button {
                        Task { await vm.signup(firstName: firstName, lastName: lastName,
                                               username: username, email: email, password: password) }
                    } label: {
                        if vm.isLoading {
                            ProgressView().frame(maxWidth: .infinity).padding()
                        } else {
                            Text("Sign Up")
                                .frame(maxWidth: .infinity).padding()
                                .background(Color.blue).foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    Button("Already have an account? Login") { showLogin = true }
                        .font(.footnote).foregroundColor(.blue)
                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(isPresented: $showLogin) { LoginView() }
        }
    }
}
