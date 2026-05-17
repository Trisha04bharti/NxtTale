import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: AuthViewModel
    @State private var identifier = ""   // email or username
    @State private var password   = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)

                TextField("Email or Username", text: $identifier)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage).foregroundColor(.red).font(.caption)
                }

                Button {
                    Task { await vm.login(identifier: identifier, password: password) }
                } label: {
                    if vm.isLoading {
                        ProgressView().frame(maxWidth: .infinity).padding()
                    } else {
                        Text("Login")
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.blue).foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                Button("Back to Sign Up") { dismiss() }
                    .font(.footnote).foregroundColor(.blue)
            }
            .padding(.horizontal, 24)
        }
    }
}
