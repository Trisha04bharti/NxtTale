import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var vm: AuthViewModel
    @State private var birthdate = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var saving = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Info") {
                    Text("\(vm.user?.firstName ?? "") \(vm.user?.lastName ?? "")")
                    Text("@\(vm.user?.username ?? "")")
                    Text(vm.user?.email ?? "")
                }

                Section("Complete Your Profile") {
                    TextField("Birthdate (YYYY-MM-DD)", text: $birthdate)

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose Profile Photo", systemImage: "photo")
                    }
                    .onChange(of: selectedPhoto) { item in
                        Task {
                            photoData = try? await item?.loadTransferable(type: Data.self)
                        }
                    }

                    if let data = photoData, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable().scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    }
                }

                Button("Save Profile") {
                    Task {
                        saving = true
                        let base64 = photoData?.base64EncodedString()
                        let updated = try? await AuthService.shared.updateProfile(
                            token: vm.token,
                            birthdate: birthdate.isEmpty ? nil : birthdate,
                            photoBase64: base64
                        )
                        if let u = updated { vm.user = u }
                        saving = false
                    }
                }
                .disabled(saving)

                Button("Logout", role: .destructive) { vm.logout() }
            }
            .navigationTitle("My Profile")
        }
    }
}
