//
//  CustomARView.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine
import TextEntity
import FocusEntity

/// A custom AR view class for handling augmented reality interactions in the Magical Garden app.
class CustomARView: ARView {
    
    // MARK: - Properties
    
    /// Handles post-processing effects.
    var postProcess: PostProcess?
    
    /// Manages save and load states.
    var saveLoadState: SaveLoadState
    
    /// Manages AR session states.
    var arState: ARState
    
    /// Manages session settings.
    var sessionSettings: SessionSettings
    
    var peopleOcclusionCancellable: AnyCancellable?
    var objectOcclusionCancellable: AnyCancellable?
    var postProcessCancellable: AnyCancellable?
    var soundCancellable: AnyCancellable?
    var animationCancellable: Set<AnyCancellable> = []
    
    /// Timers for model entities.
    var timers: [ModelEntity: Timer] = [:]
    
    /// Flags indicating if models are waiting to grow.
    var isWaitingToGrow: [ModelEntity: Bool] = [:]
    
    /// Text entities for timer display.
    var timerTextEntities: [ModelEntity: TextEntity] = [:]
    
    /// Controllers for model animations.
    var animationControllers: [ModelEntity: AnimationPlaybackController] = [:]
    
    /// Anchors for virtual objects.
    var virtualObjectAnchors: [ARAnchor] = []
    
    /// List of plants that have been placed.
    var plantsPlaced: [String] = []
    
    /// Flag indicating if the AR map is being relocalized.
    var isRelocalizingMap = false
    
    let storedData = UserDefaults.standard
    let mapKey = "ar.worldmap"
    
    /// Lazy-loaded data for the AR world map.
    lazy var worldMapData: Data? = {
        storedData.data(forKey: mapKey)
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    var selectedModelName: String = "plant1"
    var focusEntity: FocusEntity?
    
    // MARK: - Initialization
    
    /// Initializes the custom AR view with the specified frame and settings.
    required init(frame frameRect: CGRect, sessionSettings: SessionSettings, saveLoadState: SaveLoadState, arState: ARState) {
        self.sessionSettings = sessionSettings
        self.saveLoadState = saveLoadState
        self.arState = arState
        super.init(frame: frameRect)
        self.focusEntity = FocusEntity(on: self, style: .classic(color: .blue))
        postProcess = .init(arView: self)
        setup()
        subscribeToActionStream()
        initializeSettings()
        setUpSubscribers()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    // MARK: - AR Configuration and Setup
    
    /// Sets up the AR session and configures gestures.
    func setup() {
        session.run(defaultConfiguration)
        session.delegate = self
        setupGestures()
    }
    
    /// The default configuration for AR world tracking.
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        configuration.frameSemantics.insert(.personSegmentationWithDepth)
        environment.sceneUnderstanding.options.insert(.occlusion)
        environment.sceneUnderstanding.options.insert(.receivesLighting)
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        return configuration
    }
    
    // MARK: - Settings Management
    
    /// Initializes the settings for the AR view.
    func initializeSettings() {
        // updatePeopleOcclusion(isEnabled: sessionSettings.isPeopleOcclusionEnabled)
        // updateObjectOcclusion(isEnabled: sessionSettings.isObjectOcclusionEnabled)
        updatePostProcess(isEnabled: sessionSettings.isPostProcessEnabled)
        // updateSound(isEnabled: sessionSettings.isSoundEnabled)
    }
    
    /// Sets up subscribers for session settings changes.
    private func setUpSubscribers() {
        peopleOcclusionCancellable = sessionSettings.$isPeopleOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updatePeopleOcclusion(isEnabled: isEnabled)
        }
        
        objectOcclusionCancellable = sessionSettings.$isObjectOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updateObjectOcclusion(isEnabled: isEnabled)
        }
        
        postProcessCancellable = sessionSettings.$isPostProcessEnabled.sink { [weak self] isEnabled in
            self?.updatePostProcess(isEnabled: isEnabled)
        }
        
        soundCancellable = sessionSettings.$isSoundEnabled.sink { [weak self] isEnabled in
            self?.updateSound(isEnabled: isEnabled)
        }
    }
    
    // MARK: - AR Configuration Updates
    
    /// Updates the AR session to enable or disable people occlusion.
    func updatePeopleOcclusion(isEnabled: Bool) {
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            return
        }
        
        guard let configuration = session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        
        if isEnabled {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            configuration.frameSemantics.remove(.personSegmentationWithDepth)
        }
        
        session.run(configuration)
    }
    
    /// Updates the AR session to enable or disable object occlusion.
    func updateObjectOcclusion(isEnabled: Bool) {
        if (isEnabled) {
            environment.sceneUnderstanding.options.insert(.occlusion)
        } else {
            environment.sceneUnderstanding.options.remove(.occlusion)
        }
    }
    
    /// Updates the AR session to enable or disable post-processing effects.
    func updatePostProcess(isEnabled: Bool) {
        postProcess?.switchPostProcessState()
    }
    
    /// Updates the AR session to enable or disable sound effects.
    func updateSound(isEnabled: Bool) {
        if isEnabled {
            SoundManager.shared.resumeAllSounds()
        } else {
            SoundManager.shared.muteAllSounds()
        }
    }
    
    // MARK: - Helpers
    
    /// Sends a local notification to the user.
    func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Your plant needs attention!"
        content.body = "One of your plants is calling for your attention."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }
    
    /// Subscribes to action stream events from the AR manager.
    private func subscribeToActionStream() {
        ARManager.shared.actionStream.sink { [weak self] action in
            switch action {
            case .placeObject(let modelName):
                self?.selectedModelName = modelName
            case .removeAllAnchors:
                self?.scene.anchors.removeAll()
            }
        }
        .store(in: &cancellables)
    }
}
