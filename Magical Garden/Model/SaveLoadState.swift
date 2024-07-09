//
//  SaveLoadState.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import Foundation

final class SaveLoadState: ObservableObject {
    @Published var saveButton = ButtonState(isEnabled: false)
    @Published var loadButton = ButtonState(isHidden: true)
}
