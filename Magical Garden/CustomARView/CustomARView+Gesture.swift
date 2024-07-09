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
    /// Sets up gesture recognizers for the AR view.
     func setupGestures() {
         let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
         self.addGestureRecognizer(longPressGesture)
         
         let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
         self.addGestureRecognizer(panGesture)
         
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
         self.addGestureRecognizer(tapGesture)
     }
    
    /// Handles long press gesture for deleting entities.
      @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer? = nil) {
          guard sessionSettings.isEditModeEnabled else { return }
          guard let tapLocation = recognizer?.location(in: self), recognizer?.state == .began else { return }
          
          if let entity = self.entity(at: tapLocation) as? ModelEntity {
              if let anchorEntity = entity.anchor {
                  entity.removeFromParent()
                  anchorEntity.removeFromParent()
                  SoundManager.shared.playSoundEffect(fileName: "SFX_8", fileType: "wav")
              }
          }
      }
      
      /// Handles pan gesture for moving entities.
      @objc func handlePan(_ recognizer: UIPanGestureRecognizer? = nil) {
          guard sessionSettings.isEditModeEnabled else { return }
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
    // MARK: - Gesture Handlers
    
    /// Handles tap gesture for placing and interacting with objects.
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let point = sender?.location(in: self) else { return }

        // Perform a hit test to find if any entity was tapped
        let results = self.hitTest(point, query: .nearest)
        if let firstResult = results.first, let tappedModelEntity = firstResult.entity as? ModelEntity {
            print("Hit test result: \(firstResult)")
            if let animation = tappedModelEntity.availableAnimations.first {
                if let isWaitingToGrow = isWaitingToGrow[tappedModelEntity], !isWaitingToGrow {
                    let animationPlaybackController = tappedModelEntity.playAnimation(animation)
                    SoundManager.shared.playSoundEffect(fileName: "SFX_4", fileType: "wav")
                    HapticFeedbackManager.shared.generateAdvancedHapticPattern()
                    self.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: tappedModelEntity) { [weak self] event in
                        if event.playbackController == animationPlaybackController {
                            print("Animation completed!")
                            do {
                                print("Tapped: \(tappedModelEntity.name)")
                                let newModelEntity = try ModelEntity.load(named: tappedModelEntity.name + "_full.usdz")
                                newModelEntity.position = tappedModelEntity.position
                                newModelEntity.scale = tappedModelEntity.scale
                                let parentEntity = ModelEntity()
                                parentEntity.addChild(newModelEntity)
                                parentEntity.collision = tappedModelEntity.collision
                                parentEntity.name = tappedModelEntity.name + "_full"
                                self?.installGestures(for: parentEntity)
                                
                                // Replace old model entity with newModelEntity
                                if let oldAnchor = tappedModelEntity.anchor {
                                    let newAnchor = oldAnchor
                                    tappedModelEntity.removeFromParent()
                                    self?.scene.removeAnchor(oldAnchor)
                                    
                                    newAnchor.addChild(parentEntity)
                                    self?.scene.addAnchor(newAnchor)
                                    SoundManager.shared.playSoundEffect(fileName: "SFX_5", fileType: "wav")
                                    
                                    // Check if all three model types are now placed
                                    self?.checkIfAllModelTypesPlaced()
                                }
                            } catch {
                                print("Failed to load or replace model entity: \(error)")
                            }
                        }
                    }
                    .store(in: &animationCancellable)
                }
            }
        } else {
            print("No model entity tapped.")
            if sessionSettings.isPlacingModeEnabled {
                guard let hitTestResult = self.hitTest(point, types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane]).first else {
                    print("No plane hit detected.")
                    return
                }
                
                print("Placing new model at location.")
                HapticFeedbackManager.shared.generateImpactFeedback(style: .soft)
                let anchor = ARAnchor(name: "virtualObject", transform: hitTestResult.worldTransform)
                virtualObjectAnchors.append(anchor)
                self.session.add(anchor: anchor)
            
                
                // Check if all three model types are now placed
                self.checkIfAllModelTypesPlaced()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func checkIfAllModelTypesPlaced() {
        var hasModel1 = false
        var hasModel2 = false
        var hasModel3 = false
        
        scene.anchors.forEach { anchor in
            if let modelEntity = anchor.children.first as? ModelEntity {
                switch modelEntity.name {
                case ModelType.model1.rawValue:
                    hasModel1 = true
                case ModelType.model2.rawValue:
                    hasModel2 = true
                case ModelType.model3.rawValue:
                    hasModel3 = true
                default:
                    break
                }
            }
            scene.anchors.forEach { anchor in
                if let modelEntity = anchor.children.first as? ModelEntity {
                    print(modelEntity.name)
                }
            }
        }
        
        if hasModel1 && hasModel2 && hasModel3 {
            print("All three model types are placed!")
            activateMagicalEffect()
        }
    }
    
    func activateMagicalEffect() {
        HapticFeedbackManager.shared.generateAdvancedHapticPattern()
        SoundManager.shared.playSoundEffect(fileName: "SFX_7", fileType: "wav")
        postProcess?.switchPostProcessFilter(.gardenBloom)
            let modelEntitiesToApplyEffect = self.scene.anchors.compactMap { $0.children.first as? ModelEntity }
            self.emitFinalEffect(for: modelEntitiesToApplyEffect)
        
        
        HapticFeedbackManager.shared.generateAdvancedHapticPattern()
    }

    
    func emitFinalEffect(for modelEntities: [ModelEntity]) {
        for modelEntity in modelEntities {
            if #available(iOS 18.0, *) {
                modelEntity.components.set(particleSystem())
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
