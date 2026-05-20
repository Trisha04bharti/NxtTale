import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: AuthViewModel
    @State private var identifier       = ""
    @State private var password         = ""
    @State private var isPasswordVisible = false
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) var dismiss

    enum Field { case identifier, password }

    var body: some View {
        ZStack {
            // ── Background ──
            LinearGradient(
                colors: [Color.blue.opacity(0.08), Color.purple.opacity(0.05), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Top Logo Section ──
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)

                            Image(systemName: "books.vertical.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 60)

                        Text("NxtTale")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))

                        Text("Welcome back")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40)

                    // ── Form Card ──
                    VStack(spacing: 20) {

                        // Title
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sign In")
                                .font(.title2.bold())
                            Text("Enter your credentials to continue")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // ── Identifier Field ──
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email or Username")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(focusedField == .identifier ? .blue : .gray)
                                    .frame(width: 20)

                                TextField("Enter email or username", text: $identifier)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .focused($focusedField, equals: .identifier)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .password }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                focusedField == .identifier ? Color.blue : Color.clear,
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                        }

                        // ── Password Field ──
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(focusedField == .password ? .blue : .gray)
                                    .frame(width: 20)

                                if isPasswordVisible {
                                    TextField("Enter password", text: $password)
                                        .focused($focusedField, equals: .password)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            Task { await vm.login(identifier: identifier, password: password) }
                                        }
                                } else {
                                    SecureField("Enter password", text: $password)
                                        .focused($focusedField, equals: .password)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            Task { await vm.login(identifier: identifier, password: password) }
                                        }
                                }

                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                focusedField == .password ? Color.blue : Color.clear,
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                        }

                        // ── Error Message ──
                        if !vm.errorMessage.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                                Text(vm.errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(10)
                        }

                        // ── Login Button ──
                        Button {
                            focusedField = nil
                            Task { await vm.login(identifier: identifier, password: password) }
                        } label: {
                            ZStack {
                                if vm.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    HStack(spacing: 8) {
                                        Text("Sign In")
                                            .font(.headline)
                                        Image(systemName: "arrow.right")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Group {
                                    if identifier.isEmpty || password.isEmpty {
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .cornerRadius(14)
                            .shadow(
                                color: identifier.isEmpty || password.isEmpty
                                    ? .clear : Color.blue.opacity(0.4),
                                radius: 8, x: 0, y: 4
                            )
                        }
                        .disabled(identifier.isEmpty || password.isEmpty || vm.isLoading)

                        // ── Divider ──
                        HStack {
                            Rectangle().fill(Color(.systemGray4)).frame(height: 1)
                            Text("or").font(.caption).foregroundColor(.secondary).padding(.horizontal, 8)
                            Rectangle().fill(Color(.systemGray4)).frame(height: 1)
                        }

                        // ── Back to Sign Up ──
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundColor(.secondary)
                                Text("Sign Up")
                                    .foregroundColor(.blue)
                                    .bold()
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
