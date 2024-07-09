//
//  CustomARView+Session.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import Foundation
import RealityKit
import ARKit

extension CustomARView: ARSessionDelegate {
    
    // MARK: - ARSessionDelegate
    
    /// Called when the camera's tracking state changes.
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// Called when ARKit adds anchors to the scene.
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("did add anchor: \(anchors.count) anchors in total")
        
        for anchor in anchors {
            addAnchorEntityToScene(anchor: anchor)
        }
    }
    
    /// Called when ARKit updates the session frame.
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .extending, .mapped:
            saveLoadState.saveButton.isEnabled =
                virtualObjectAnchors.first != nil && frame.anchors.contains(where: { $0 == virtualObjectAnchors.first })
        default:
            saveLoadState.saveButton.isEnabled = false
        }
        arState.mappingStatus = """
        Mapping: \(frame.worldMappingStatus.description)
        Tracking: \(frame.camera.trackingState.description)
        """
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    /// Called when the AR session is interrupted.
    func sessionWasInterrupted(_ session: ARSession) {
        arState.sessionInfoLabel = "Session was interrupted"
    }
    
    /// Called when the AR session interruption ends.
    func sessionInterruptionEnded(_ session: ARSession) {
        arState.sessionInfoLabel = "Session interruption ended"
    }
    
    /// Called when the AR session encounters an error.
    func session(_ session: ARSession, didFailWithError error: Error) {
        arState.sessionInfoLabel = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            print("ERROR: \(errorMessage)")
            print("TODO: show error as an alert.")
        }
    }
    
    /// Determines if ARKit should attempt to relocalize.
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    // MARK: - Private Methods
    
    /// Updates the session info label based on AR tracking and mapping status.
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        var message: String
        
        arState.isThumbnailHidden = true
        switch (trackingState, frame.worldMappingStatus) {
        case (.normal, .mapped), (.normal, .extending):
            if frame.anchors.contains(where: { $0.name == "virtualObject" }) {
                message = "Tap 'Save Experience' to keep track of your plants."
            } else {
                message = "Tap on the screen to place a plant on a plane surface."
            }
            
        case (.normal, _) where self.worldMapData != nil && !self.isRelocalizingMap:
            message = "Move around to map the environment or tap 'Load Experience' to resume nurturing your plants."
            
        case (.normal, _) where self.worldMapData == nil:
            message = "Move around to map the environment and place your plants."
            
        case (.limited(.relocalizing), _) where self.isRelocalizingMap:
            message = "Align your device with the shown image to continue nurturing your plants."
            arState.isThumbnailHidden = false
            
        default:
            message = trackingState.localizedFeedback
        }
        
        arState.sessionInfoLabel = message
    }
}
