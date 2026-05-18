//
//  logo.swift
//  NxtTale
//
//  Created by Vikram Kumar on 18/05/26.
//

import SwiftUI

struct OkalyLogo : View {
    
    var size : CGFloat = 80
    var color : Color = .white
    
    var body: some View {
        Image("logo")
            .resizable()
            .scaledToFit()
            .frame(width: 80 , height: size)
            .foregroundStyle(color)
            
    }
}


struct PrivacyStatementView : View {
    var body: some View {
        
        HStack{
            Text("By Continuing you agree to our")
            
            
            Text("Privacy Policy")
                .fontWeight(.semibold)
        }
        .foregroundStyle(Color.gray.opacity(0.7))
        .font(.footnote)
        
    }
}
