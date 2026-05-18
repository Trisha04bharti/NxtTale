//
//  SplashView.swift
//  NxtTale
//
//  Created by Vikram Kumar on 18/05/26.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
          /*  OnboardingView()*/ // next screen
            OnboardingView()
        } else {
            ZStack {

                
                Image("background1")
                               .resizable()
                               .scaledToFill()
                               .ignoresSafeArea()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
