//
//  CustomARView+Timer.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 14/07/24.
//

import Foundation
import RealityFoundation
import TextEntity

extension CustomARView {
    
    // MARK: - Timer  Management
    
    func startRandomTimer(for modelEntity: ModelEntity) {
        let randomTimeInterval = TimeInterval.random(in: 30...180)
        addTimerText(to: modelEntity, countdown: randomTimeInterval)
        
        let timer = Timer.scheduledTimer(withTimeInterval: randomTimeInterval, repeats: false) { [weak self] _ in
            self?.emitSubtleEffect(for: modelEntity)
            self?.sendLocalNotification()
            self?.isWaitingToGrow[modelEntity] = false
            self?.removeTimerText(from: modelEntity)
        }
        
        timers[modelEntity] = timer
    }
    
    func addTimerText(to modelEntity: ModelEntity, countdown: TimeInterval) {
        let textEntity = TextEntity(text: formatTime(countdown))
        textEntity.position.y = 0.2
        modelEntity.addChild(textEntity)
        timerTextEntities[modelEntity] = textEntity
        
        for secondsLeft in (0...Int(countdown)).reversed() {
            let delayInSeconds = Double(Int(countdown) - secondsLeft)
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                textEntity.text = self.formatTime(Double(secondsLeft))
            }
        }
    }
    
    // Function to format time based on seconds or minutes
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        if timeInterval < 60 {
            return "\(Int(timeInterval))s"
        } else {
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%dm %02ds", minutes, seconds)
        }
    }
    
    
    func removeTimerText(from modelEntity: ModelEntity) {
        if let textEntity = timerTextEntities[modelEntity] {
            textEntity.removeFromParent()
            timerTextEntities.removeValue(forKey: modelEntity)
        }
    }
    
    func updateTimerText(entity: ModelEntity, countdown: TimeInterval) {
        guard let textEntity = timerTextEntities[entity] else {
            return
        }
        
        textEntity.text = "\(Int(countdown))s"
    }
}
