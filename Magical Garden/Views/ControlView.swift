//
//  ControlView.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 06/07/24.
//

import SwiftUI
import RealityKit

struct ControlView: View {
    @Binding var selectedModel: String
    @State var selectedOptionIndex = 0
    @State var showDropdown = false
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    @EnvironmentObject var arState: ARState
    @EnvironmentObject var sessionSettings: SessionSettings
    
    var body: some View {
        VStack {
            
            HStack {
                DropDownMenu(options: ["Placement Mode", "Edit Mode", "Interact Mode"],
                             selectedOptionIndex: $selectedOptionIndex,
                             showDropdown: $showDropdown)
                
                Spacer()
                
                Button(action: {
                    
                    arState.resetButton.isPressed = true
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundStyle(metallicBlue)
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
            }
            if !sessionSettings.isHelpDebugEnabled {
                Spacer()
            }
            ControlButtonBar(showSettings: $showSettings, selectedModel: $selectedModel, showBrowse: $showBrowse)
        }
    }
}

struct ControlButtonBar: View {
    @Binding var showSettings: Bool
    @Binding var selectedModel: String
    @Binding var showBrowse: Bool
    var body: some View {
        
        HStack {
            Button {
                
            } label: {
                Image(selectedModel)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .buttonStyle(PlainButtonStyle())
                    .clipShape(.rect(cornerRadius: 8))
            }
            .frame(width: 30, height: 30)
            Spacer()
            Button {
                self.showBrowse.toggle()
            } label: {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 30, height: 30)
            .sheet(isPresented: $showBrowse) {
                BrowseSheetView(selectedModel: $selectedModel, showBrowse: $showBrowse)
            }
            Spacer()
            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 30, height: 30)
            .sheet(isPresented: $showSettings) {
                SettingsView(showSettings: $showSettings)
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
        .padding(30)
        .background(.black.opacity(0.25))
    }
}


struct BrowseSheetView: View {
    @Binding var selectedModel: String
    @Binding var showBrowse: Bool
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                HorizontalGrid(selectedModel: $selectedModel, showBrowse: $showBrowse)
            }
            .navigationTitle("Your Magical Garden")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing:
                                    Button {
                self.showBrowse.toggle()
            } label: {
                Text("Done")
                    .bold()
            }
            )
        }
    }
}

struct HorizontalGrid: View {
    @Binding var selectedModel: String
    @Binding var showBrowse: Bool
    let items : [Model] = Models().all
    private let gridItemLayout:[GridItem] = [GridItem(.fixed(150))]
    var body: some View {
        VStack(alignment: .leading) {
            Text("Plants")
                .font(.title2).bold()
                .padding(.leading, 22)
                .padding(.top, 10)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: gridItemLayout, spacing: 30) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Button {
                            selectedModel = self.items[index].name
                            self.showBrowse.toggle()
                        } label: {
                            Image(uiImage: self.items[index].thumbnail)
                                .resizable()
                                .frame(width: 150, height: 150)
                                .cornerRadius(8)
                        }
                        
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
            }
        }
    }
}

class Model {
    var name: String
    var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    init(name: String, scaleCompensation: Float) {
        self.name = name
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
    }
}

struct Models {
    var all: [Model] = []
    init () {
        let plant1 = Model(name: "plant1", scaleCompensation: 0.32/100)
        let plant2 = Model(name: "plant2", scaleCompensation: 0.32/100)
        let plant3 = Model(name: "plant3", scaleCompensation: 0.32/100)
        self.all += [plant1, plant2, plant3]
    }
    
}
