//
//  onBoardingView.swift
//  NxtTale
//
//  Created by Vikram Kumar on 18/05/26.
//

//import SwiftUI
//
//struct OnboardingView : View {
//    
//    @EnvironmentObject var vm: AuthViewModel
//    
//    var body: some View {
//        NavigationStack{
//            ZStack{
//                Image("bb")
//                    .resizable()
//                    .scaledToFill()
//                    .ignoresSafeArea()
//                
//                VStack{
//                    VStack{
//                      
////                        OkalyLogo()
//                        Image("logo")
//                                  .resizable()
//                                  .scaledToFit()
//                                  .frame(width: 80 , height: 80)
//                                  .foregroundStyle(.white)
//                        
//                        Text("Save and Invest with Oakly")
//                        
//                    }
//                    .padding(.top , 40)
//                    
//                    Spacer()
//                    
//                    NavigationLink(
//                        destination: SignUpView(),
//                        tag: 1,
//                        selection: $vm.viewState.navigate
//                    ) {
//                        Text("Get Started")
//                            .foregroundStyle(Color.white)
//                            .frame(width: 290 , height: 40)
//                            .background(Color.green)
//                            .cornerRadius(20)
//                    }
//                    
//                    HStack{
//                        Text("Already have an account ?")
//                            .foregroundStyle(Color.white)
//                        
//                        Button("Log in"){
//                            
//                        }
//
//                        .foregroundStyle(Color.green)
//                    }
//                    
//                    
//                    
//                    .padding()
//                    
//                }
//                
//                
//                
//                
//                
//                
//            }
//        }
//    }
//}

import SwiftUI

struct OnboardingView: View {

    @EnvironmentObject var vm: AuthViewModel
    @State private var navigateToSignup = false

    var body: some View {

        NavigationStack {

            ZStack {

                Image("bb")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    
                    VStack{
                                        
              OkalyLogo()
         Text("Save and Invest with Oakly")
                  }
          .padding(.top , 40)
                                      
                                    

                    Spacer()

                    Button {
                        navigateToSignup = true
                    } label: {

                        Text("Get Started")
                            .foregroundStyle(.white)
                            .frame(width: 290, height: 40)
                            .background(Color.green)
                            .cornerRadius(20)
                    }

                }
            }
            .navigationDestination(isPresented: $navigateToSignup) {
                SignUpView()
            }
        }
    }
}

#Preview {
    OnboardingView()
}
