//
//  SessionSettings.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 07/07/24.
//

import Foundation

class SessionSettings: ObservableObject {
    @Published var isNightModeEnabled: Bool = false
    @Published var isSoundEnabled: Bool = true
    @Published var isVibrationEnabled: Bool = true
    
    @Published var isPeopleOcclusionEnabled: Bool = false
    @Published var isObjectOcclusionEnabled: Bool = false
    @Published var isHelpDebugEnabled: Bool = true
    @Published var isPostProcessEnabled: Bool = false
    
    @Published var isPlacingModeEnabled: Bool = true
    @Published var isEditModeEnabled: Bool = false
    @Published var isInteractModeEnabled: Bool = false
}
