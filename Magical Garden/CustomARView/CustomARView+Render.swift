//
//  CustomARView+Renderer.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import Foundation
import RealityKit
import ARKit

extension CustomARView {
    
    // MARK: - Reset Tracking
    
    /// Resets AR session tracking and removes existing anchors.
    func resetTracking() {
        self.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
        self.isRelocalizingMap = false
        self.virtualObjectAnchors.removeAll()
        SoundManager.shared.playSoundEffect(fileName: "SFX_7", fileType: "wav")
    }
    
    // MARK: - Anchor Management
    
    /// Adds an anchor entity to the AR scene.
    /// - Parameter anchor: The ARAnchor to add.
    func addAnchorEntityToScene(anchor: ARAnchor) {
        guard anchor.name == "virtualObject" else {
            return
        }
        
        do {
            let modelEntity = try ModelEntity.load(named: selectedModelName + ".usdz")
            
            let parentEntity = ModelEntity()
            parentEntity.addChild(modelEntity)
            parentEntity.name = selectedModelName
            print("added: \(selectedModelName)")
            
            let entityBounds = modelEntity.visualBounds(relativeTo: parentEntity)
            parentEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: entityBounds.extents).offsetBy(translation: entityBounds.center)])
            
            installGestures(for: parentEntity)
            
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(parentEntity)
            isWaitingToGrow[parentEntity] = true
            scene.addAnchor(anchorEntity)
            
            startRandomTimer(for: parentEntity)
            
            if #available(iOS 18.0, *) {
                parentEntity.components.set(particleSystemBurst())
            } else {
                // Fallback on earlier versions
            }
            
            SoundManager.shared.playSoundEffect(fileName: "SFX_1", fileType: "wav")
            self.plantsPlaced.append(selectedModelName)
            
        } catch {
            print("Failed to load model: \(error.localizedDescription)")
        }
    }
}
