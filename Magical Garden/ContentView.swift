//
//  ContentView.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 01/07/24.
//

import SwiftUI
import AVFoundation
import ARKit

/// The main content view of the Magical Garden app.
struct ContentView: View {
    
    /// The state object managing save and load operations.
    @StateObject var saveLoadState = SaveLoadState()
    
    /// The state object managing AR state.
    @StateObject var arState = ARState()
    
    /// The available plant options.
    let options = ["plant1", "plant2", "plant3"]
    
    /// The currently selected model.
    @State private var selectedModel: String = "plant1"
    
    /// A flag indicating whether the browse view is shown.
    @State private var showBrowse: Bool = false
    
    /// A flag indicating whether the settings view is shown.
    @State private var showSettings: Bool = false
    
    /// The list of plants that have been placed.
    @State var plantsPlaced: [String] = []
    
    var body: some View {
        ZStack {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            ControlView(selectedModel: $selectedModel, showSettings: $showSettings)
        }
        .environmentObject(saveLoadState)
        .environmentObject(arState)
        .onChange(of: selectedModel) { newModel in
            selectedModel = newModel
            ARManager.shared.sendAction(.placeObject(modelName: newModel))
        }
    }
}

/// The container view for the AR view.
struct ARViewContainer: UIViewRepresentable {
    
    /// The environment object containing save and load state.
    @EnvironmentObject var saveLoadState: SaveLoadState
    
    /// The environment object containing AR state.
    @EnvironmentObject var arState: ARState
    
    /// The environment object containing session settings.
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
        uiView.focusEntity?.isEnabled = sessionSettings.isHelpDebugEnabled

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
    
    /// Shows an alert to confirm garden reset.
    /// - Parameter uiView: The AR view to reset.
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
