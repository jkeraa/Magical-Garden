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

/// Enumeration defining actions related to AR interactions.
enum ARAction {
    case placeObject(modelName: String)
    case removeAllAnchors
}

/// Singleton class responsible for managing AR actions.
final class ARManager: ObservableObject {
    
    /// Shared instance of ARManager accessible throughout the app.
    static let shared = ARManager()
    
    /// Subject for publishing AR actions.
    let actionStream = PassthroughSubject<ARAction, Never>()
    
    private init() { }
    
    /// Sends an AR action to subscribers.
    ///
    /// - Parameter action: The AR action to send.
    func sendAction(_ action: ARAction) {
        actionStream.send(action)
    }
}
