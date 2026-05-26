

import SwiftUI
import PhotosUI

struct ProfileView: View {

    @EnvironmentObject var authVM: AuthViewModel

    @State private var birthdate = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var saving = false
    @State private var showLogoutAlert = false

    var profileImage: UIImage? {

        if let data = photoData {
            return UIImage(data: data)
        }

        if let photo = authVM.user?.profilePhoto,
           let data = Data(base64Encoded: photo) {

            return UIImage(data: data)
        }

        return nil
    }

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottom) {

                // MARK: - Background

                Color(.systemBackground)
                    .ignoresSafeArea()

                // MARK: - Bottom Green Glow

                RadialGradient(
                    colors: [
                        Color.green.opacity(0.35),
                        Color.green.opacity(0.15),
                        Color.clear
                    ],
                    center: .bottom,
                    startRadius: 20,
                    endRadius: 350
                )
                .frame(height: 350)
                .offset(y: 120)
                .ignoresSafeArea()

                // MARK: - Main Content

                ScrollView {

                    VStack(spacing: 0) {

                        // ───────── Header Banner ─────────

                        ZStack(alignment: .bottom) {

                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.green.opacity(0.8),
                                            Color.green.opacity(0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 160)

                            // MARK: Profile Photo

                            PhotosPicker(
                                selection: $selectedPhoto,
                                matching: .images
                            ) {

                                ZStack(alignment: .bottomTrailing) {

                                    if let img = profileImage {

                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 4)
                                            )
                                            .shadow(radius: 8)

                                    } else {

                                        Circle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: 100, height: 100)

                                            .overlay(

                                                Text(
                                                    authVM.user?
                                                        .firstName
                                                        .prefix(1) ?? "U"
                                                )
                                                .font(
                                                    .system(
                                                        size: 40,
                                                        weight: .bold
                                                    )
                                                )
                                                .foregroundColor(.white)
                                            )

                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        Color.white,
                                                        lineWidth: 4
                                                    )
                                            )

                                            .shadow(radius: 8)
                                    }

                                    // MARK: Camera Icon

                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 30, height: 30)

                                        .overlay(

                                            Image(systemName: "camera.fill")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        )

                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    Color.white,
                                                    lineWidth: 2
                                                )
                                        )
                                }
                            }
                            .offset(y: 50)

                            .onChange(of: selectedPhoto) { item in

                                Task {

                                    photoData = try? await item?
                                        .loadTransferable(type: Data.self)
                                }
                            }
                        }

                        // ───────── Name Section ─────────

                        VStack(spacing: 4) {

                            Text(
                                "\(authVM.user?.firstName ?? "") \(authVM.user?.lastName ?? "")"
                            )
                            .font(.title2.bold())

                            Text("@\(authVM.user?.username ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 24)

                        // ───────── Info Cards ─────────

                        VStack(spacing: 1) {

                            InfoRow(
                                icon: "envelope.fill",
                                color: .blue,
                                title: "Email",
                                value: authVM.user?.email ?? ""
                            )

                            InfoRow(
                                icon: "at",
                                color: .purple,
                                title: "Username",
                                value: authVM.user?.username ?? ""
                            )

                            // MARK: Birthdate

                            HStack(spacing: 14) {

                                Circle()
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 36, height: 36)

                                    .overlay(

                                        Image(systemName: "calendar")
                                            .foregroundColor(.orange)
                                            .font(.subheadline)
                                    )

                                VStack(
                                    alignment: .leading,
                                    spacing: 2
                                ) {

                                    Text("Birthdate")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    TextField(
                                        "YYYY-MM-DD",
                                        text: $birthdate
                                    )
                                    .font(.subheadline)

                                    .onAppear {

                                        birthdate =
                                            authVM.user?.birthdate ?? ""
                                    }
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // ───────── Save Button ─────────

                        Button {

                            Task {

                                saving = true

                                let base64 =
                                    photoData?.base64EncodedString()

                                let updated = try? await
                                    AuthService.shared.updateProfile(
                                        token: authVM.token,
                                        birthdate: birthdate.isEmpty
                                            ? nil
                                            : birthdate,
                                        photoBase64: base64
                                    )

                                if let u = updated {
                                    authVM.user = u
                                }

                                saving = false
                            }

                        } label: {

                            if saving {

                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(14)

                            } else {

                                Text("Save Changes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)

                        // ───────── Logout ─────────

                        Button {

                            showLogoutAlert = true

                        } label: {

                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(14)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 40)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)

            .alert("Logout", isPresented: $showLogoutAlert) {

                Button("Cancel", role: .cancel) {}

                Button("Logout", role: .destructive) {
                    authVM.logout()
                }

            } message: {

                Text("Are you sure you want to logout?")
            }
        }
    }
}


// MARK: - Reusable Info Row

struct InfoRow: View {

    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {

        HStack(spacing: 14) {

            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 36, height: 36)

                .overlay(

                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.subheadline)
                )

            VStack(alignment: .leading, spacing: 2) {

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
    }
}


