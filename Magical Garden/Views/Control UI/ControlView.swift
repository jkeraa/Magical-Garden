//
//  ControlView.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 06/07/24.
//

import SwiftUI

/// A view that provides control buttons for interacting with the AR experience.
struct ControlView: View {
    
    /// The currently selected model.
    @Binding var selectedModel: String
    
    /// A flag indicating whether the settings view is shown.
    @Binding var showSettings: Bool
    
    /// The environment object containing AR state information.
    @EnvironmentObject var arState: ARState
    
    /// The environment object containing session settings.
    @EnvironmentObject var sessionSettings: SessionSettings
    
    /// A flag indicating whether the items are shown.
    @State var showItems = false
    
    /// A flag indicating whether the UI is hidden.
    @State private var isUIHidden = false
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 60, height: 30)
                    
                    Button {
                        withAnimation {
                            isUIHidden.toggle()
                            sessionSettings.isHelpDebugEnabled.toggle()
                        }
                    } label: {
                        Image(systemName: isUIHidden ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(metallicBlue)
                    }
                    .contentTransition(.symbolEffect(.replace))
                }
                Spacer()
                
                ZStack {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 60, height: 30)
                    
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 15))
                            .foregroundStyle(metallicBlue)
                    }
                    .frame(width: 30, height: 30)
                    .sheet(isPresented: $showSettings) {
                        SettingsView(showSettings: $showSettings)
                    }
                }
            }
            .padding()
            
            if sessionSettings.isHelpDebugEnabled {
                HStack {
                    if !arState.isThumbnailHidden {
                        if let image = arState.thumbnailImage {
                            SnapshotThumbnail(image: image)
                                .frame(width: 100, height: 200)
                                .aspectRatio(contentMode: .fit)
                                .padding(.leading, 10)
                        }
                    }
                    Spacer()
                }
                
                Spacer()
                
                SessionInfo(label: arState.sessionInfoLabel)
                SaveLoadButton()
                    .padding(.bottom, 10)
            }
            
            if !sessionSettings.isHelpDebugEnabled {
                Spacer()
            }
            
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 60, height: 60)
                    
                    if #available(iOS 18.0, *) {
                        Button {
                            arState.resetButton.isPressed = true
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 30))
                                .foregroundStyle(.red)
                        }
                        .symbolEffect(.rotate, options: .speed(3), value: arState.resetButton.isPressed)
                    } else {
                        Button {
                            arState.resetButton.isPressed = true
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 30))
                                .foregroundStyle(.red)
                        }
                    }
                }
                Spacer()
                ZStack {
                    Button {
                        selectModel("plant1")
                    } label: {
                        ItemButton(isIcon: false, image: "plant1", selectedModel: $selectedModel)
                    }
                    .offset(y: showItems ? -210 : 0)
                    
                    Button {
                        selectModel("plant2")
                    } label: {
                        ItemButton(isIcon: false, image: "plant2", selectedModel: $selectedModel)
                    }
                    .offset(y: showItems ? -140 : 0)
                    
                    Button {
                        selectModel("plant3")
                    } label: {
                        ItemButton(isIcon: false, image: "plant3", selectedModel: $selectedModel)
                    }
                    .offset(y: showItems ? -70 : 0)
                    
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                            showItems.toggle()
                        }
                    } label: {
                        ItemButton(isIcon: true, image: "plant1", selectedModel: $selectedModel)
                    }
                    .symbolEffect(.bounce, options: .speed(1), value: showItems)
                }
            }
            .padding()
        }
        .onAppear {
            selectedModel = "plant1"
            print("Model selected at start: \(selectedModel)")
        }
    }
    
    /// Selects a model and toggles the display of items.
    /// - Parameter model: The name of the model to select.
    private func selectModel(_ model: String) {
        selectedModel = model
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
            showItems.toggle()
        }
    }
}

/// A view representing an item button.
struct ItemButton: View {
    
    /// Indicates whether the button is an icon.
    var isIcon: Bool
    
    /// The image name for the button.
    var image: String
    
    /// The currently selected model.
    @Binding var selectedModel: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 60, height: 60)
            
            if isIcon {
                Image(systemName: "plus")
                    .font(.system(size: 30))
                    .foregroundStyle(metallicBlue)
            } else {
                if selectedModel == image {
                    Image(image)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.green, lineWidth: 2)
                        )
                } else {
                    Image(image)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
            }
        }
    }
}
