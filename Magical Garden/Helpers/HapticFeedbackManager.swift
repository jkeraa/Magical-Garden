//
//  HapticFeedbackManager.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 08/07/24.
//

import UIKit
import CoreHaptics

class HapticFeedbackManager {
    
    // MARK: - Singleton
    
    static let shared = HapticFeedbackManager()

    // MARK: - Properties
    
    private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
    private var notificationGenerator = UINotificationFeedbackGenerator()
    private var selectionGenerator = UISelectionFeedbackGenerator()
    
    private var hapticEngine: CHHapticEngine?
    private var supportsHaptics: Bool = false

    // MARK: - Initialization
    
    private init() {
        preloadHapticGenerators()
        setupHapticEngine()
    }

    // MARK: - Preloading Haptic Generators
    
    /// Preloads the haptic generators with different impact styles.
    private func preloadHapticGenerators() {
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy, .soft, .rigid]
        for style in styles {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            impactGenerators[style] = generator
        }
        
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    // MARK: - Haptic Engine Setup
    
    /// Sets up the haptic engine and starts it.
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            supportsHaptics = false
            return
        }

        supportsHaptics = true
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            hapticEngine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
            hapticEngine?.resetHandler = { [weak self] in
                do {
                    try self?.hapticEngine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }

    // MARK: - Haptic Feedback Methods
    
    /// Generates impact feedback with the specified style.
    func generateImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        impactGenerators[style]?.impactOccurred()
    }

    /// Generates notification feedback with the specified type.
    func generateNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }

    /// Generates selection feedback.
    func generateSelectionFeedback() {
        selectionGenerator.selectionChanged()
    }

    /// Generates an advanced haptic pattern.
    func generateAdvancedHapticPattern() {
        guard supportsHaptics, let hapticEngine = hapticEngine else {
            print("Haptics not supported or haptic engine not initialized")
            return
        }

        do {
            let pattern = try createGrowingHapticPattern()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play advanced haptic pattern: \(error)")
        }
    }

    // MARK: - Haptic Pattern Creation
    
    /// Creates a growing haptic pattern.
    func createGrowingHapticPattern() throws -> CHHapticPattern {
        var events = [CHHapticEvent]()
        let rhythmParams = [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
        ]
        for i in stride(from: 0, to: 1, by: 0.01) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.0)
            let attack = CHHapticEventParameter(parameterID: .attackTime, value: 0.01)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, attack, sharpness], relativeTime: TimeInterval(i))
            events.append(event)
        }
        return try CHHapticPattern(events: events, parameterCurves: [])
    }
}
