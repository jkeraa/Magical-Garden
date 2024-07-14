//
//  CustomARView+Particles.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 14/07/24.
//

import Foundation
import RealityKit
import ARKit

extension CustomARView {
    
    // MARK: - Particle Systems
    
    /// Creates the repeating particle system that happens when the plants needs water.
    /// - Returns: A configured `ParticleEmitterComponent`.
    @available(iOS 18.0, *)
    func particleSystem() -> ParticleEmitterComponent {
        var particles = ParticleEmitterComponent.Presets.magic
        particles.timing = .repeating(
            warmUp: 0,
            emit: ParticleEmitterComponent.Timing.VariableDuration(duration: 2),
            idle: ParticleEmitterComponent.Timing.VariableDuration(duration: 0)
        )
        particles.emitterShape = .point
        particles.mainEmitter.stretchFactor = 1
        particles.birthLocation = .surface
        particles.birthDirection = .local
        particles.emissionDirection = [0, 0, 1]
        particles.mainEmitter.vortexDirection = [0, 0, 1]
        particles.emitterShapeSize = [1, 1, 1] * 0.05
        particles.speed = 0.1
        particles.mainEmitter.birthRate = 50
        particles.mainEmitter.sortOrder = .decreasingAge
        particles.mainEmitter.size = 0.02
        particles.mainEmitter.acceleration = [0, 0.5, 0]
        particles.mainEmitter.sizeMultiplierAtEndOfLifespan = 0
        particles.mainEmitter.color = .evolving(start: .single(.white), end: .single(.yellow))
        particles.mainEmitter.colorEvolutionPower = 1
        particles.mainEmitter.spreadingAngle = 360
        particles.mainEmitter.lifeSpan = 1
        particles.mainEmitter.opacityCurve = .linearFadeOut
        
        return particles
    }
    
    /// Creates the particle system for the final magical effect with sparkling entities flying around.
    /// - Returns: A configured `ParticleEmitterComponent`.
    @available(iOS 18.0, *)
    func finalParticleSystem() -> ParticleEmitterComponent {
        var particles = ParticleEmitterComponent.Presets.magic
        particles.timing = .repeating(
            warmUp: 0,
            emit: ParticleEmitterComponent.Timing.VariableDuration(duration: 0.1),
            idle: ParticleEmitterComponent.Timing.VariableDuration(duration: 0.9)
        )
        particles.emitterShape = .sphere
        particles.mainEmitter.stretchFactor = 1
        particles.birthLocation = .surface
        particles.birthDirection = .local
        particles.emissionDirection = [0, 0, 1]
        particles.mainEmitter.vortexDirection = [0, 0, 0]
        particles.emitterShapeSize = [1, 1, 1] * 0.1
        particles.speed = 1.0
        particles.mainEmitter.sortOrder = .decreasingAge
        particles.mainEmitter.size = 0.05
        particles.mainEmitter.acceleration = [0, -0.2, 0] // Gravity effect
        particles.mainEmitter.sizeMultiplierAtEndOfLifespan = 0
        particles.mainEmitter.color = .evolving(
            start: .single(.blue),
            end: .random(a: .white, b: .cyan)
        )
        particles.mainEmitter.colorEvolutionPower = 1
        particles.mainEmitter.spreadingAngle = 360
        particles.mainEmitter.birthRate = 150
        particles.mainEmitter.lifeSpan = 3
        particles.mainEmitter.opacityCurve = .linearFadeOut
        
        return particles
    }
    
    /// Creates a particle system for a burst effect used when the plant is placed for a "dirt" effect.
    /// - Returns: A configured `ParticleEmitterComponent`.
    @available(iOS 18.0, *)
    func particleSystemBurst() -> ParticleEmitterComponent {
        var particles = ParticleEmitterComponent.Presets.impact
        
        // Set the particle system timing to a single burst
        particles.timing = .repeating(
            warmUp: 0,
            emit: ParticleEmitterComponent.Timing.VariableDuration(duration: 1),
            idle: ParticleEmitterComponent.Timing.VariableDuration(duration: 1)
        )
        
        // Set the emitter shape and properties
        particles.emitterShape = .plane
        particles.birthLocation = .surface
        particles.birthDirection = .local
        particles.emissionDirection = [0, 1, 0] // Emit upwards for a burst effect
        particles.emitterShapeSize = [1, 1, 1] * 0.05
        particles.speed = 1.5
        
        // Configure the main emitter properties
        particles.mainEmitter.birthRate = 500 // High birth rate for a burst
        particles.mainEmitter.size = 0.05
        particles.mainEmitter.acceleration = [0, -1, 0] // Gravity effect
        particles.mainEmitter.sizeMultiplierAtEndOfLifespan = 0.5
        particles.mainEmitter.color = .evolving(start: .single(.brown), end: .single(.red))
        particles.mainEmitter.colorEvolutionPower = 1.0
        particles.mainEmitter.spreadingAngle = 360
        particles.mainEmitter.lifeSpan = 1
        particles.mainEmitter.opacityCurve = .linearFadeOut
        
        // Enable burst effect
        particles.isEmitting = false
        particles.burstCount = 500 // Number of particles in the burst
        particles.burst()
        
        return particles
    }
}
