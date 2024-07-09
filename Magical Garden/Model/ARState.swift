//
//  ARState.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import Foundation
import SwiftUI

final class ARState: ObservableObject {
    @Published var sessionInfoLabel = "Initializing"
    @Published var isThumbnailHidden = true
    @Published var thumbnailImage: UIImage?
    @Published var mappingStatus = "Mapping: "
    @Published var resetButton = ButtonState()
    @Published var placedModels: Set<String> = []
}
