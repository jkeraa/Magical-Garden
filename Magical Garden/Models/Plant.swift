//
//  Plant.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 01/07/24.
//

import SwiftData
import Foundation

@Model
class Plant {
    @Attribute var positionX: Float
    @Attribute var positionY: Float
    @Attribute var positionZ: Float
    @Attribute var growthStage: Int
    @Attribute var timerState: Double

    init(positionX: Float, positionY: Float, positionZ: Float, growthStage: Int, timerState: Double) {
        self.positionX = positionX
        self.positionY = positionY
        self.positionZ = positionZ
        self.growthStage = growthStage
        self.timerState = timerState
    }
}

