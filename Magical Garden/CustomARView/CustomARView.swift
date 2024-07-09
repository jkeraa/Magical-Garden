//
//  CustomARView.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

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
import UserNotifications
import TextEntity
import AVFoundation

class CustomARView: ARView {
    
    // MARK: - Properties
    
     var postProcess: PostProcess?
    var saveLoadState: SaveLoadState
    var arState: ARState
    var sessionSettings: SessionSettings
    
    var peopleOcclusionCancellable: AnyCancellable?
    var objectOcclusionCancellable: AnyCancellable?
    var helpDebugCancellable: AnyCancellable?
    var postProcessCancellable: AnyCancellable?
    var animationCancellable: Set<AnyCancellable> = []
    
    private var timers: [ModelEntity: Timer] = [:]
    var isWaitingToGrow: [ModelEntity: Bool] = [:]
    private var timerTextEntities: [ModelEntity: TextEntity] = [:]
    private var audioPlayer: AVAudioPlayer?
    var audioEffectPlayer: AVAudioPlayer?
    var virtualObjectAnchors: [ARAnchor] = []
    var isRelocalizingMap = false
    
    let storedData = UserDefaults.standard
    let mapKey = "ar.worldmap"
    lazy var worldMapData: Data? = {
        storedData.data(forKey: mapKey)
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    var selectedModelName: String = "plant1"
    
    // MARK: - Initialization
    
    required init(frame frameRect: CGRect, sessionSettings: SessionSettings, saveLoadState: SaveLoadState, arState: ARState) {
        self.sessionSettings = sessionSettings
        self.saveLoadState = saveLoadState
        self.arState = arState
        super.init(frame: frameRect)
        
        postProcess = .init(arView: self)
        setup()
        subscribeToActionStream()
        initializeSettings()
        setUpSubscribers()
        
        SoundManager.shared.playBackgroundMusic(fileName: "Music", fileType: "wav")
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    // MARK: - AR Configuration and Setup
    
     func setup() {
        session.run(defaultConfiguration)
        session.delegate = self
        setupGestures()
        debugOptions = [.showFeaturePoints, .showSceneUnderstanding]
    }
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        return configuration
    }
    
    // MARK: - Settings Management
    
    func initializeSettings() {
        updatePeopleOcclusion(isEnabled: sessionSettings.isPeopleOcclusionEnabled)
        updateObjectOcclusion(isEnabled: sessionSettings.isObjectOcclusionEnabled)
        updateHelpDebug(isEnabled: sessionSettings.isHelpDebugEnabled)
    }
    
    private func setUpSubscribers() {
        peopleOcclusionCancellable = sessionSettings.$isPeopleOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updatePeopleOcclusion(isEnabled: isEnabled)
        }
        
        objectOcclusionCancellable = sessionSettings.$isObjectOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updateObjectOcclusion(isEnabled: isEnabled)
        }
        
        helpDebugCancellable = sessionSettings.$isHelpDebugEnabled.sink { [weak self] isEnabled in
            self?.updateHelpDebug(isEnabled: isEnabled)
        }
        
        postProcessCancellable = sessionSettings.$isPostProcessEnabled.sink { [weak self] isEnabled in
            self?.updatePostProcess(isEnabled: isEnabled)
        }
    }
    
    // MARK: - AR Configuration Updates
    
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
    
    func updateObjectOcclusion(isEnabled: Bool) {
        if isEnabled {
            environment.sceneUnderstanding.options.insert(.occlusion)
        } else {
            environment.sceneUnderstanding.options.remove(.occlusion)
        }
    }
    
    func updateHelpDebug(isEnabled: Bool) {
        if isEnabled {
            debugOptions.insert(.showFeaturePoints)
        } else {
            debugOptions.remove(.showFeaturePoints)
        }
    }
    
    func updatePostProcess(isEnabled: Bool) {
        postProcess?.switchPostProcessState()
    }
    
    
    // MARK: - Timers and Effects
    
    func startRandomTimer(for modelEntity: ModelEntity) {
        let randomTimeInterval = TimeInterval.random(in: 30...180)
        addTimerText(to: modelEntity, countdown: randomTimeInterval)
        
        let timer = Timer.scheduledTimer(withTimeInterval: randomTimeInterval, repeats: false) { [weak self] _ in
            self?.emitSubtleEffect(for: modelEntity)
            self?.sendLocalNotification()
            self?.isWaitingToGrow[modelEntity] = false
            self?.removeTimerText(from: modelEntity)
        }
        
        timers[modelEntity] = timer
    }
    
    func emitSubtleEffect(for modelEntity: ModelEntity) {
        var jumpTransform = modelEntity.transform
        jumpTransform.translation.y += 0.1
        let originalTransform = modelEntity.transform
        
        func animateJump() {
            modelEntity.move(to: jumpTransform, relativeTo: modelEntity.parent, duration: 0.5, timingFunction: .easeInOut)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                modelEntity.move(to: originalTransform, relativeTo: modelEntity.parent, duration: 0.5, timingFunction: .easeInOut)
            }
            
            let particleEntity = ModelEntity(mesh: .generateSphere(radius: 0.03))
            var material = SimpleMaterial()
            material.baseColor = .color(.cyan)
            particleEntity.model?.materials = [material]
            
            particleEntity.transform.translation = modelEntity.transform.translation
            particleEntity.transform.translation.y += 0.2
            particleEntity.transform.translation.x += 0.2
            particleEntity.name = "particles"
            
            modelEntity.addChild(particleEntity)
            if #available(iOS 18.0, *) {
                modelEntity.components.set(particleSystem())
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                particleEntity.removeFromParent()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                animateJump()
            }
        }
        
        animateJump()
        
        SoundManager.shared.playSoundEffect(fileName: "SFX_2", fileType: "wav")
    }
    
    // MARK: - Notifications
    
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
    
    // MARK: - Timer Text Management
    
    func addTimerText(to modelEntity: ModelEntity, countdown: TimeInterval) {
        let textEntity = TextEntity(text: formatTime(countdown))
        textEntity.position.y = 0.2
        modelEntity.addChild(textEntity)
        timerTextEntities[modelEntity] = textEntity
        
        for secondsLeft in (0...Int(countdown)).reversed() {
            let delayInSeconds = Double(Int(countdown) - secondsLeft)
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                textEntity.text = self.formatTime(Double(secondsLeft))
            }
        }
    }

    // Function to format time based on seconds or minutes
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        if timeInterval < 60 {
            return "\(Int(timeInterval))s"
        } else {
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%dm %02ds", minutes, seconds)
        }
    }

    
    func removeTimerText(from modelEntity: ModelEntity) {
        if let textEntity = timerTextEntities[modelEntity] {
            textEntity.removeFromParent()
            timerTextEntities.removeValue(forKey: modelEntity)
        }
    }
    
    func updateTimerText(entity: ModelEntity, countdown: TimeInterval) {
        guard let textEntity = timerTextEntities[entity] else {
            return
        }
        
        textEntity.text = "\(Int(countdown))s"
    }
    
    // MARK: - Utility
    
    @available(iOS 18.0, *)
    func particleSystem() -> ParticleEmitterComponent {
        var particles = ParticleEmitterComponent()
        particles.emitterShape = .sphere
        particles.emitterShapeSize = [1, 1, 1] * 0.05
        
        particles.mainEmitter.birthRate = 50
        particles.mainEmitter.size = 0.03
        particles.mainEmitter.acceleration = particles.mainEmitter.acceleration / 2
        particles.mainEmitter.lifeSpan = 2
        particles.mainEmitter.color = .evolving(start: .single(.white),
                                                end: .single(.cyan))
        return particles
    }
    
    // MARK: - Private Helpers
    
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
