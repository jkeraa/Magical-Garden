//
//  SessionSettings.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 07/07/24.
//

import Foundation

/// Manages the settings for the session, enabling or disabling various features.
class SessionSettings: ObservableObject {
    
    @Published var isSoundEnabled: Bool = true
    
    @Published var isPeopleOcclusionEnabled: Bool = true

    @Published var isObjectOcclusionEnabled: Bool = true
    
    @Published var isHelpDebugEnabled: Bool = true
    
    @Published var isPostProcessEnabled: Bool = true
}
