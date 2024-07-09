//
//  ARManager.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 02/07/24.
//

import Foundation
import Combine
import RealityKit
import ARKit

enum ARAction {
    case placeObject(modelName: String)
    case removeAllAnchors
}

final class ARManager: ObservableObject {
    static let shared = ARManager()
    let actionStream = PassthroughSubject<ARAction, Never>()
    
    private init() { }
    
    func sendAction(_ action: ARAction) {
        actionStream.send(action)
    }
}


extension ARView: @retroactive ARCoachingOverlayViewDelegate {
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()

        // Goal is a field that indicates your app's tracking requirements.
        coachingOverlay.goal = .horizontalPlane
             
        // The session this view uses to provide coaching.
        coachingOverlay.session = self.session
             
        // How a view should resize itself when its superview's bounds change.
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        

        self.addSubview(coachingOverlay)
    }
}

