//
//  ProfilePopupView.swift
//  NxtTale
//
//  Created by Vikram Kumar on 17/05/26.
//

import SwiftUI

struct ProfilePopupView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) { isShowing = false }
                }

            VStack(spacing: 20) {

                // Close button
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring()) { isShowing = false }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)

                // Large profile image
                ZStack {
                    if let photo = authVM.user?.profilePhoto,
                       let data  = Data(base64Encoded: photo),
                       let uiImg = UIImage(data: data) {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 20)
                    } else {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 160, height: 160)
                            .overlay(
                                Text(authVM.user?.firstName.prefix(1) ?? "U")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    }
                }

                // Name + username
                VStack(spacing: 6) {
                    Text("\(authVM.user?.firstName ?? "") \(authVM.user?.lastName ?? "")")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("@\(authVM.user?.username ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Text(authVM.user?.email ?? "")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()
            }
            .padding(.top, 60)
        }
    }
}
