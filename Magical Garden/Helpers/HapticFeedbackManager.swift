//
//  HapticFeedbackManager.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 08/07/24.
//

import UIKit
import CoreHaptics

/// Manages haptic feedback for the Magical Garden application.
class HapticFeedbackManager {
    
    static let shared = HapticFeedbackManager()
    
    private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
    private var notificationGenerator = UINotificationFeedbackGenerator()
    private var selectionGenerator = UISelectionFeedbackGenerator()
    
    private var hapticEngine: CHHapticEngine?
    private var supportsHaptics: Bool = false
    
    private init() {
        setupHapticEngine()
    }
    
    /// Preloads haptic generators for efficient feedback.
    func preloadHapticGenerators() {
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy, .soft]
        for style in styles {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            impactGenerators[style] = generator
        }
        
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    /// Sets up the haptic engine and checks for hardware support.
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
    
    /// Generates impact feedback using the specified style.
    /// - Parameter style: The feedback style to use.
    func generateImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        impactGenerators[style]?.impactOccurred()
        impactGenerators[style]?.prepare() // Prepare for next use
    }
    
    /// Generates notification feedback of the specified type.
    /// - Parameter type: The type of notification feedback to generate.
    func generateNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
        notificationGenerator.prepare() // Prepare for next use
    }
    
    /// Generates selection feedback.
    func generateSelectionFeedback() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare() // Prepare for next use
    }
    
    /// Generates an advanced haptic pattern for enhanced feedback.
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
    
    /// Creates a growing haptic pattern with varying intensity.
    /// - Throws: An error if the pattern cannot be created.
    private func createGrowingHapticPattern() throws -> CHHapticPattern {
        var events = [CHHapticEvent]()
        for i in stride(from: 0, to: 1.6, by: 0.01) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: TimeInterval(i))
            events.append(event)
        }
        return try CHHapticPattern(events: events, parameterCurves: [])
    }
    
    /// Clears cached haptic generators and stops the haptic engine.
    func clearCache() {
        impactGenerators.removeAll()
        notificationGenerator = UINotificationFeedbackGenerator()
        selectionGenerator = UISelectionFeedbackGenerator()
        hapticEngine?.stop()
        hapticEngine = nil
    }
}
