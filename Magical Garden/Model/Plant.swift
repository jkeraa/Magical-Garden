//
//  DropDownMenu.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import SwiftData
import Foundation
import SwiftUI
import RealityKit
import Combine

class Plant: Identifiable, Hashable {
    var id = UUID()
    var modelName: String
    var image: UIImage?
    var modelEntity: ModelEntity?
    private var cancellables: AnyCancellable? = nil

    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)
        
        let fileName = modelName + ".usdz"
        self.cancellables = ModelEntity.loadModelAsync(named: fileName).sink(receiveCompletion: { loadCompletion in
            print("Unable to load model entity for modelName: \(self.modelName)")
        }, receiveValue: { modelEntity in
            self.modelEntity = modelEntity
        })
    }

    // Conforming to Hashable
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

