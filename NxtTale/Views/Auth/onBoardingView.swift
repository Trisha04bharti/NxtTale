

//import SwiftUI
//
//struct OnboardingView: View {
//
//    @EnvironmentObject var vm: AuthViewModel
//    @State private var navigateToSignup = false
//
//    var body: some View {
//
//        NavigationStack {
//
//            ZStack {
//
//                Image("bb")
//                    .resizable()
//                    .scaledToFill()
//                    .ignoresSafeArea()
//
//                VStack {
//                    
//                    VStack{
//                                        
//              OkalyLogo()
//         Text("Every Story Begins Somewhere")
//                  }
//          .padding(.top , 40)
//                                      
//                                    
//
//                    Spacer()
//
//                    Button {
//                        navigateToSignup = true
//                    } label: {
//
//                        Text("Get Started")
//                            .foregroundStyle(.white)
//                            .frame(width: 290, height: 40)
//                            .background(Color.green)
//                            .cornerRadius(20)
//                    }
//                    
//                    HStack{
//                   Text("Already have an account ?")
//                           .foregroundStyle(Color.white)
//                                         
//                        Button("Log in"){
//                                             
//                                         }
//                                         .foregroundStyle(Color.green)
//                                     }
//
//                }
//            }
//            .navigationDestination(isPresented: $navigateToSignup) {
//                SignUpView()
//            }
//        }
//    }
//}
//


import SwiftUI

struct OnboardingView: View {

    @EnvironmentObject var vm: AuthViewModel

    @State private var navigateToSignup = false
    @State private var navigateToLogin = false

    var body: some View {

        NavigationStack {

            ZStack {

                Image("bb")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {

                    VStack {

                        OkalyLogo()

                        Text("Every Story Begins Somewhere")
                           

                    }
                    .padding(.top, 40)

                    Spacer()

                    // Get Started Button
                    Button {

                        navigateToSignup = true

                    } label: {

                        Text("Get Started")
                            .foregroundStyle(.white)
                            .frame(width: 290, height: 40)
                            .background(Color.green)
                            .cornerRadius(20)
                    }

                    // Login Section
                    HStack {

                        Text("Already have an account ?")
                            .foregroundStyle(.white)

                        Button("Log in") {

                            navigateToLogin = true
                        }
                        .foregroundStyle(.green)
                    }
                    .padding(.top, 8)
                }
            }

            // Navigate to SignUp
            .navigationDestination(isPresented: $navigateToSignup) {

                SignUpView()
            }

            // Navigate to Login
            .navigationDestination(isPresented: $navigateToLogin) {

                LoginView()
            }
        }
    }
}

//#Preview {
//    OnboardingView()
//}

//#Preview {
//    OnboardingView()
//}
