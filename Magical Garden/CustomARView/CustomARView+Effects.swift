//
//  CustomARView+Effects.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 14/07/24.
//

import Foundation
import RealityKit
import ARKit

extension CustomARView {
    
    // MARK: - Model Placement Checks
    
    /// Checks if all plants are in stage "2" of growth placed in the scene and activates magical effects if true.
    func checkIfAllModelTypesPlaced() {
        var hasModel1 = false
        var hasModel2 = false
        var hasModel3 = false
        
        scene.anchors.forEach { anchor in
            if let modelEntity = anchor.children.first as? ModelEntity {
                switch modelEntity.name {
                case ModelType.model1.rawValue:
                    hasModel1 = true
                    print("Found model1: \(modelEntity.name)")
                case ModelType.model2.rawValue:
                    hasModel2 = true
                    print("Found model2: \(modelEntity.name)")
                case ModelType.model3.rawValue:
                    hasModel3 = true
                    print("Found model3: \(modelEntity.name)")
                default:
                    break
                }
                if hasModel1, hasModel2, hasModel3 {
                    print("All three model types are placed!")
                }
            }
            
            scene.anchors.forEach { anchor in
                if let modelEntity = anchor.children.first as? ModelEntity {
                    print("Entity in scene: \(modelEntity.name)")
                }
            }
        }
        
        if hasModel1 && hasModel2 && hasModel3 {
            print("All three model types are placed!")
            activateMagicalEffect()
            resumeAnimationsForAllModels()
        }
    }
    
    // MARK: - Particle and Animation Control
    
    /// Removes particles and stops the jump animation for a given model entity.
    /// - Parameter modelEntity: The model entity to modify.
    func removeParticlesAndStopJump(for modelEntity: ModelEntity) {
        print("Children before removal: \(modelEntity.children.map { $0.name })")
        
        modelEntity.children.filter { $0.name == "particles" }.forEach {
            print("Removing particle entity: \($0)")
            $0.removeFromParent()
        }
        
        print("Stopping all animations and resetting transform")
        modelEntity.stopAllAnimations()
        if let stopComponent = modelEntity.components[StopAnimationComponent.self] {
            stopComponent.shouldAnimate.pointee = false
        }
        var originalTransform = modelEntity.transform
        originalTransform.translation.y = 0.0
        modelEntity.move(to: originalTransform, relativeTo: modelEntity.parent, duration: 0.5, timingFunction: .easeInOut)
        
        if #available(iOS 18.0, *), let _ = modelEntity.components[ParticleEmitterComponent.self] {
            modelEntity.components.remove(ParticleEmitterComponent.self)
        }
        
        print("Children after removal: \(modelEntity.children.map { $0.name })")
    }
    
    /// Resumes animations for all models after a delay.
    func resumeAnimationsForAllModels() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            for (_, animationController) in self.animationControllers {
                animationController.resume()
            }
        }
    }
    
    // MARK: - Magical Effects Activation
    
    /// Activates magical effects when all model types are placed.
    func activateMagicalEffect() {
        // HapticFeedbackManager.shared.generateAdvancedHapticPattern()
        SoundManager.shared.playBackgroundMusic(fileName: "Music", fileType: "wav")
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            // self.postProcess?.switchPostProcessFilter(.gardenBloom)
        }
        let modelEntitiesToApplyEffect = self.scene.anchors.compactMap { $0.children.first as? ModelEntity }
        self.emitFinalEffect(for: modelEntitiesToApplyEffect)
        
        // HapticFeedbackManager.shared.generateAdvancedHapticPattern()
    }
    
    // MARK: - Particle Effects
    
    /// Emits the final particle effect for all the grown plants.
    /// - Parameter modelEntities: The list of model entities to apply the effect to.
    func emitFinalEffect(for modelEntities: [ModelEntity]) {
        for modelEntity in modelEntities {
            if #available(iOS 18.0, *) {
                let pointLight = PointLight()
                pointLight.light.intensity = 80000
                pointLight.light.color = UIColor(metallicBlue)
                pointLight.light.attenuationRadius = 400
                pointLight.light.attenuationFalloffExponent = 2
                pointLight.position = [0, 1.5, 0]
                
                modelEntity.components.set(finalParticleSystem())
                modelEntity.anchor?.addChild(pointLight)
                print("POSITION: \(pointLight.position.y)")
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    /// Emits a subtle particle effect and makes the plant jump.
    /// - Parameter modelEntity: The model entity to apply the effect to.
    func emitSubtleEffect(for modelEntity: ModelEntity) {
        var jumpTransform = modelEntity.transform
        jumpTransform.translation.y += 0.1
        let originalTransform = modelEntity.transform
        
        var shouldAnimate = true
        
        func animateJump() {
            guard shouldAnimate else { return }
            
            modelEntity.move(to: jumpTransform, relativeTo: modelEntity.parent, duration: 0.5, timingFunction: .easeInOut)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard shouldAnimate else { return }
                modelEntity.move(to: originalTransform, relativeTo: modelEntity.parent, duration: 0.5, timingFunction: .easeInOut)
            }
            
            let particleEntity = ModelEntity(mesh: .generateSphere(radius: 0.01))
            var material = SimpleMaterial()
            material.baseColor = .color(UIColor(metallicBlue))
            particleEntity.model?.materials = [material]
            
            particleEntity.transform.translation = modelEntity.transform.translation
            particleEntity.transform.translation.y += 0.2
            particleEntity.transform.translation.x += 0.1
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
        modelEntity.components.set(StopAnimationComponent(shouldAnimate: &shouldAnimate))
    }
    
    // MARK: - Stop Animation Component
    
    /// Component to control stopping of animation.
    struct StopAnimationComponent: Component {
        var shouldAnimate: UnsafeMutablePointer<Bool>
    }
}
