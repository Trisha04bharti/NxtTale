//
//  SplashView.swift
//  NxtTale
//
//  Created by Vikram Kumar on 18/05/26.
//
//
//import SwiftUI
//
//struct SplashView: View {
//    @State private var isActive = false
//
//    var body: some View {
//        if isActive {
//          /*  OnboardingView()*/ // next screen
//            OnboardingView()
//        } else {
//            ZStack {
//
//                
//                Image("background1")
//                               .resizable()
//                               .scaledToFill()
//                               .ignoresSafeArea()
//            }
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                    withAnimation {
//                        isActive = true
//                    }
//                }
//            }
//        }
//    }
//}

import SwiftUI

struct SplashView: View {

    @State private var isActive = false
    @State private var animateLogo = false

    var body: some View {

        if isActive {

            OnboardingView()

        } else {

            ZStack {

                // Green Background
                Color.green
                    .ignoresSafeArea()

                // Logo Animation
                Image("butterfly")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: animateLogo ? 180 : 500,
                        height: animateLogo ? 180 : 500
                    )
                    .scaleEffect(animateLogo ? 1 : 3)
                    .opacity(animateLogo ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 1.2),
                        value: animateLogo
                    )
            }
            .onAppear {

                // Start animation
                animateLogo = true

                // Navigate after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {

                    withAnimation {

                        isActive = true   
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
