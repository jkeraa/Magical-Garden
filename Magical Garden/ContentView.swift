//
//  ContentView.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 01/07/24.
//

import SwiftUI
import AVFoundation
import ARKit

struct ContentView: View {
    @StateObject var saveLoadState = SaveLoadState()
    @StateObject var arState = ARState()
    let options = ["plant1", "plant2", "plant3"]
    
    @State private var selectedOption: String = "plant1"
    
    @State private var showBrowse: Bool = false
    @State private var showSettings: Bool = false
    
    var body: some View {
        ZStack {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            ControlView(selectedModel: $selectedOption, showBrowse: $showBrowse, showSettings: $showSettings)
        }
        .environmentObject(saveLoadState)
        .environmentObject(arState)
        .onChange(of: selectedOption) { newModel in
            ARManager.shared.sendAction(.placeObject(modelName: newModel))
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var saveLoadState: SaveLoadState
    @EnvironmentObject var arState: ARState
    @EnvironmentObject var sessionSettings: SessionSettings
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> CustomARView {
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("ARKit is not available on this device.")
        }
        
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings, saveLoadState: saveLoadState, arState: arState)
        
        if arView.worldMapData != nil {
            saveLoadState.loadButton.isHidden = false
        }
        
        arView.setup()
        UIApplication.shared.isIdleTimerDisabled = true
        arView.addCoaching()
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {
        if saveLoadState.saveButton.isPressed {
            uiView.saveExperience()
            DispatchQueue.main.async {
                self.saveLoadState.saveButton.isPressed = false
            }
        }
        
        if saveLoadState.loadButton.isPressed {
            uiView.loadExperience()
            self.saveLoadState.loadButton.isPressed = false
        }
        
        if arState.resetButton.isPressed {
            showResetAlert(uiView: uiView)
            DispatchQueue.main.async {
                self.arState.resetButton.isPressed = false
            }
        }
    }
    
    private func showResetAlert(uiView: CustomARView) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(title: "Reset Garden", message: "Are you sure you want to reset your garden?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
            uiView.resetTracking()
        }))
        
        rootViewController.present(alert, animated: true, completion: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
