import SwiftUI
import PhotosUI

// MARK: - Enhanced ProfileView

struct ProfileView: View {

    @EnvironmentObject var authVM: AuthViewModel

    @State private var birthdate = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var saving = false
    @State private var saveSuccess = false
    @State private var showLogoutAlert = false
    @State private var animateGradient = false

    var profileImage: UIImage? {
        if let data = photoData { return UIImage(data: data) }
        if let photo = authVM.user?.profilePhoto,
           let data = Data(base64Encoded: photo) {
            return UIImage(data: data)
        }
        return nil
    }

    var userInitials: String {
        let first = authVM.user?.firstName.prefix(1) ?? ""
        let last  = authVM.user?.lastName.prefix(1) ?? ""
        return "\(first)\(last)".uppercased().isEmpty ? "U" : "\(first)\(last)"
    }

    // Deterministic gradient pair from username
    var avatarColors: [Color] {
        let palette: [[Color]] = [
            [.purple, .indigo],
            [.blue,   .cyan],
            [.green,  .teal],
            [.orange, .pink],
            [.red,    .purple]
        ]
        let idx = (authVM.user?.username.hashValue ?? 0) % palette.count
        return palette[abs(idx)]
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                // MARK: Background
                Color(.systemBackground).ignoresSafeArea()

                // MARK: Bottom glow
                RadialGradient(
                    colors: [Color.green.opacity(0.2), Color.clear],
                    center: .bottom,
                    startRadius: 10,
                    endRadius: 320
                )
                .frame(height: 300)
                .offset(y: 100)
                .ignoresSafeArea()

                // MARK: Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        headerBanner
                        nameSection
                        statsBar
                        infoCards
                        actionButtons
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Logout", role: .destructive) { authVM.logout() }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }

    // MARK: - Header Banner

    private var headerBanner: some View {
        ZStack(alignment: .bottom) {

            // Animated mesh gradient background
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                MeshGradient(
                    width: 3, height: 3,
                    points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5],
                        [Float(0.4 + 0.15 * sin(t * 0.4)), Float(0.5 + 0.1 * cos(t * 0.3))],
                        [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ],
                    colors: [
                        .green.opacity(0.9), .teal.opacity(0.7), .green.opacity(0.6),
                        .mint.opacity(0.5),  .green,              .teal.opacity(0.8),
                        .green.opacity(0.4), .teal.opacity(0.3),  .green.opacity(0.5)
                    ]
                )
            }
            .frame(height: 200)

            // Subtle noise overlay for texture
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.15))
                .frame(height: 200)

            // Profile photo
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    avatarView
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.9), .white.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3.5
                                )
                        )
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)

                    // Camera badge
                    Circle()
                        .fill(.white)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
            }
            .offset(y: 52)
            .onChange(of: selectedPhoto) { item in
                Task {
                    photoData = try? await item?.loadTransferable(type: Data.self)
                }
            }
        }
    }

    @ViewBuilder
    private var avatarView: some View {
        if let img = profileImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(
                    LinearGradient(
                        colors: avatarColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Text(userInitials)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                )
        }
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(spacing: 5) {
            Text("\(authVM.user?.firstName ?? "") \(authVM.user?.lastName ?? "")")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            HStack(spacing: 4) {
                Text("@\(authVM.user?.username ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Image(systemName: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.top, 64)
        .padding(.bottom, 20)
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: 0) {
            statItem(value: "128", label: "Posts")
            Divider().frame(height: 32)
            statItem(value: "1.2K", label: "Following")
            Divider().frame(height: 32)
            statItem(value: "4.8K", label: "Followers")
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Info Cards

    private var infoCards: some View {
        VStack(spacing: 12) {

            EnhancedInfoRow(
                icon: "envelope.fill",
                gradient: [.blue, .cyan],
                title: "Email",
                value: authVM.user?.email ?? ""
            )

            EnhancedInfoRow(
                icon: "at",
                gradient: [.purple, .indigo],
                title: "Username",
                value: "@\(authVM.user?.username ?? "")"
            )

            // Birthdate row with DatePicker feel
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)

                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Birthdate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("YYYY-MM-DD", text: $birthdate)
                        .font(.subheadline.weight(.medium))
                        .onAppear { birthdate = authVM.user?.birthdate ?? "" }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {

            // Save button
            Button {
                Task { await handleSave() }
            } label: {
                ZStack {
                    if saving {
                        ProgressView()
                            .tint(.white)
                    } else if saveSuccess {
                        Label("Saved!", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Group {
                        if saveSuccess {
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            LinearGradient(
                                colors: [Color.blue, Color(hex: "0099FF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(
                    color: saveSuccess ? .green.opacity(0.4) : .blue.opacity(0.35),
                    radius: 10, x: 0, y: 5
                )
            }
            .disabled(saving || saveSuccess)
            .animation(.spring(response: 0.4), value: saveSuccess)

            // Logout button
            Button {
                showLogoutAlert = true
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.subheadline.weight(.semibold))
                    Text("Logout")
                        .font(.headline)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 48)
    }

    // MARK: - Save Logic

    @MainActor
    private func handleSave() async {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        saving = true

        let base64 = photoData?.base64EncodedString()
        let updated = try? await AuthService.shared.updateProfile(
            token: authVM.token,
            birthdate: birthdate.isEmpty ? nil : birthdate,
            photoBase64: base64
        )
        if let u = updated { authVM.user = u }

        saving = false

        withAnimation { saveSuccess = true }
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        try? await Task.sleep(nanoseconds: 2_000_000_000)
        withAnimation { saveSuccess = false }
    }
}

// MARK: - Enhanced Info Row

struct EnhancedInfoRow: View {

    let icon: String
    let gradient: [Color]
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Hex Color Helper

extension Color {
    init(hex: String) {
        let v = Int(hex, radix: 16) ?? 0
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8)  & 0xFF) / 255
        let b = Double(v         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
