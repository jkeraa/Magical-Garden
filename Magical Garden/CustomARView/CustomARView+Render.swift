//
//  CustomArView+Renderer.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import Foundation
import RealityKit
import ARKit

extension CustomARView {
    
    func resetTracking() {
        self.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
        self.isRelocalizingMap = false
        self.virtualObjectAnchors.removeAll()
    }
    
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
            
            SoundManager.shared.playSoundEffect(fileName: "SFX_1", fileType: "wav")
        } catch {
            print("Failed to load model: \(error.localizedDescription)")
        }
    }
}
