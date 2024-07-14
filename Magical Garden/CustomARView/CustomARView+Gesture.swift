//
//  CustomARView+Gesture.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import SwiftUI
import ARKit
import RealityKit

extension CustomARView {
    
    // MARK: - Properties
    
    enum ModelType: String {
        case model1 = "plant1_full"
        case model2 = "plant2_full"
        case model3 = "plant3_full"
    }
    
    // MARK: - Gesture Setup
    
    /// Sets up gesture recognizers for the AR view.
    func setupGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        self.addGestureRecognizer(longPressGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Gesture Handlers
    
    /// Handles long press gesture for deleting entities.
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer? = nil) {
        guard let tapLocation = recognizer?.location(in: self), recognizer?.state == .began else { return }
        
        if let entity = self.entity(at: tapLocation) as? ModelEntity {
            if let anchorEntity = entity.anchor {
                entity.removeFromParent()
                anchorEntity.removeFromParent()
                plantsPlaced.removeAll(where: { $0 == entity.name })
                SoundManager.shared.playSoundEffect(fileName: "SFX_8", fileType: "wav")
            }
        }
    }
    
    /// Handles pan gesture for moving entities.
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer? = nil) {
        guard let translation = recognizer?.translation(in: self), let tapLocation = recognizer?.location(in: self), recognizer?.state == .began else { return }
        
        if let entity = self.entity(at: tapLocation) as? ModelEntity {
            self.scene.anchors.forEach { anchor in
                if anchor.children.contains(entity) {
                    anchor.position.x += Float(translation.x) / 1000
                    anchor.position.z += Float(translation.y) / 1000
                    recognizer?.setTranslation(.zero, in: self)
                }
            }
        }
    }
    
    /// Handles tap gesture for placing and interacting with objects.
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let point = sender?.location(in: self) else { return }

        // Perform a hit test to find if any entity was tapped
        let results = self.hitTest(point, query: .nearest)
        if let firstResult = results.first, let tappedModelEntity = firstResult.entity as? ModelEntity {
            print("Hit test result: \(firstResult)")
            print("VALUES: \(isWaitingToGrow.values)")
            if let animation = tappedModelEntity.availableAnimations.first {
                if let isWaitingToGrowTemp = isWaitingToGrow[tappedModelEntity] {
                    if !isWaitingToGrowTemp {
                        isWaitingToGrow[tappedModelEntity] = true
                        
                        // Remove particles and stop jump animation
                        removeParticlesAndStopJump(for: tappedModelEntity)
                        
                        // Play the animation
                        let animationPlaybackController = tappedModelEntity.playAnimation(animation)
                        animationControllers[tappedModelEntity] = animationPlaybackController
                        SoundManager.shared.playSoundEffect(fileName: "SFX_4", fileType: "wav")
                        
                        // Update the name
                        tappedModelEntity.name = "\(tappedModelEntity.name)_full"
                        
                        // Pause the animation after 2 seconds
                        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                            animationPlaybackController.pause()
                        }
                        
                    } else {
                        print("Already grown")
                    }
                }
                // Check if all three model types are now placed
                self.checkIfAllModelTypesPlaced()
            }
        } else {
            print("No model entity tapped.")
           
            guard let hitTestResult = self.hitTest(point, types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane]).first else {
                print("No plane hit detected.")
                return
            }

            if let focusIsOnPlane = self.focusEntity?.onPlane {
                if focusIsOnPlane {
                    print("Placing new model at location.")
                    HapticFeedbackManager.shared.generateImpactFeedback(style: .soft)
                    let anchor = ARAnchor(name: "virtualObject", transform: hitTestResult.worldTransform)
                    virtualObjectAnchors.append(anchor)
                    self.session.add(anchor: anchor)
                } else {
                    print("Not on plane")
                }
            } else {
                print("Focus entity not loaded")
            }
        }
    }
}
