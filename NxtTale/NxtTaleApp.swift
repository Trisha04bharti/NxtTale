//
//  NxtTaleApp.swift
//  NxtTale
//
//  Created by Vikram Kumar on 16/05/26.
//

//import SwiftUI
//
//@main
//struct NxtTaleApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

import SwiftUI

@main
struct NxtTaleApp: App {
    @StateObject var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                MainTabView()
                    .environmentObject(authVM)
            } else {
                SignUpView()
                    .environmentObject(authVM)
            }
        }
    }
}
