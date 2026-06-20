

import SwiftUI

@main

struct NxtTaleApp : App {
    
    @StateObject var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                MainTabView()
                    .environmentObject(authVM)
            } else {
                SplashView()
                    .environmentObject(authVM)
                
            }
        }
        
    }
    
}
