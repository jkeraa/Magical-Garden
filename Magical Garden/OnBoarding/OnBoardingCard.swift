//
//  OnBoardingCard.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import SwiftUI

struct OnBoardingCard: View {
    var onBoardingItem: OnBoardingItem
    var isCurrentPage: Bool
  
    @State private var isAnimating: Bool = false
    @State var frameSideMeasure = UIScreen.main.bounds.width / 1.2
    @State var imageSideMeasure = UIScreen.main.bounds.width / 1.3
    
    @Binding var indexCard: Int?
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                
                Text(onBoardingItem.title)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 40, weight: .medium, design: .default))
                    .frame(width: UIScreen.main.bounds.width, alignment: .center)
                    .fontWeight(.heavy)
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 2, x: 2, y: 2)
                
                Spacer()
                
                onBoardingItem.image
                    .resizable()
                    .symbolEffect(.pulse)
                    .symbolEffect(.scale.up)
                   
                    .scaledToFit()
                    .frame(width: imageSideMeasure / 1, height: imageSideMeasure / 2)
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 8, x: 6, y: 8)
                    .foregroundStyle(metallicBlue)
                
                Spacer()
                
                Text(onBoardingItem.description)
                    .foregroundColor(Color.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating.toggle()
            }
        }
        .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.width, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .cornerRadius(20)
        .padding(.horizontal, 10)
    }
}

