//
//  OnBoardingView.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import SwiftUI
import Foundation

/// View for onboarding users with a series of onboarding cards.
struct OnBoardingView: View {
    var onBoardingItem: [OnBoardingItem] = onBoardingData
    var opacityEffect: Bool = false
    var clipEdges: Bool = false
    @State var indexCard: Int? = 0
    
    @State private var currentPage: Int = 0
    @AppStorage("isOnboarded") var isOnboarded: Bool?
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(Array(onBoardingItem.enumerated()), id: \.offset) { index, item in
                            OnBoardingCard(
                                onBoardingItem: item,
                                isCurrentPage: currentPage == index,
                                indexCard: $indexCard
                            )
                            .padding(.horizontal, 5)
                            .containerRelativeFrame(.horizontal)
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                    .overlay(alignment: .bottom) {
                        PagingIndicator(
                            activeTint: metallicBlue,
                            inactiveTint: .gray.opacity(0.5),
                            opacityEffect: opacityEffect,
                            clipEdges: clipEdges
                        )
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            self.currentPage = 0
                        }
                    }
                }
                .scrollPosition(id: $indexCard)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.paging)
                
                Spacer()
                
                HStack {
                    Spacer()
                    NavigationLink(destination: ContentView()
                        .navigationBarBackButtonHidden()
                        .onAppear {
                            isOnboarded = true
                        }) {
                            Capsule()
                                .fill(metallicBlue)
                                .frame(width: 150, height: 40)
                                .overlay {
                                    Text("Skip the onboarding")
                                        .foregroundStyle(.white)
                                        .font(.caption)
                                        .padding()
                                }
                        }
                        .buttonStyle(.plain)
                }
                .padding()
                Spacer()
            }
        }
    }
}

/// View for the paging indicator in the onboarding process.
struct PagingIndicator: View {
    var activeTint: Color = .primary
    var inactiveTint: Color = .gray
    var opacityEffect: Bool = false
    var clipEdges: Bool = false
    
    var body: some View {
        let hstackSpacing: CGFloat = 10
        let dotHeight: CGFloat = 6
        let inactiveWidth: CGFloat = 16
        let activeWidth: CGFloat = 64
        
        GeometryReader { geometry in
            let width = geometry.size.width
            
            if let scrollViewWidth = geometry.bounds(of: .scrollView(axis: .horizontal))?.width,
               scrollViewWidth > 0 {
                
                let minX = geometry.frame(in: .scrollView(axis: .horizontal)).minX
                let totalPages = Int(width / scrollViewWidth)
                
                let freeProgress = -minX / scrollViewWidth
                let clippedProgress = min(max(freeProgress, 0), CGFloat(totalPages - 1))
                let progress = clipEdges ? clippedProgress : freeProgress
                
                let activeIndex = Int(progress)
                let nextIndex = Int(progress.rounded(.awayFromZero))
                let indicatorProgress = progress - CGFloat(activeIndex)
                
                let currentPageWidth = inactiveWidth + ((1 - indicatorProgress) * (activeWidth - inactiveWidth))
                let nextPageWidth = inactiveWidth + (indicatorProgress * (activeWidth - inactiveWidth))
                
                HStack(spacing: hstackSpacing) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(index == activeIndex || index == nextIndex ? activeTint : inactiveTint)
                            .frame(width: (index == activeIndex) ? currentPageWidth : (index == nextIndex) ? nextPageWidth : inactiveWidth,
                                   height: dotHeight)
                            .opacity(opacityEffect ?
                                     (index == activeIndex) ? 1 - indicatorProgress : (index == nextIndex) ? indicatorProgress : 1
                                     : 1
                            )
                    }
                }
                .frame(width: scrollViewWidth)
                .offset(x: -minX)
            }
        }
        .frame(height: 30)
    }
}
