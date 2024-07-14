//
//  Extensions.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import simd
import ARKit
import RealityKit
import SwiftUI

// MARK: - ARFrame.WorldMappingStatus Extension

extension ARFrame.WorldMappingStatus: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .extending:
            return "Extending"
        case .mapped:
            return "Mapped"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - ARCamera.TrackingState Extension

extension ARCamera.TrackingState: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .normal:
            return "Normal"
        case .notAvailable:
            return "Not Available"
        case .limited(.initializing):
            return "Initializing"
        case .limited(.excessiveMotion):
            return "Excessive Motion"
        case .limited(.insufficientFeatures):
            return "Insufficient Features"
        case .limited(.relocalizing):
            return "Relocalizing"
        case .limited:
            return "Unspecified Reason"
        }
    }
}

// MARK: - ARCamera TrackingState Extension for Localized Feedback

extension ARCamera.TrackingState {
    var localizedFeedback: String {
        switch self {
        case .normal:
            return "Move around to map the environment."
        case .notAvailable:
            return "Tracking unavailable."
        case .limited(.excessiveMotion):
            return "Move the device more slowly."
        case .limited(.insufficientFeatures):
            return "Point the device at an area with visible surface detail, or improve lighting conditions."
        case .limited(.relocalizing):
            return "Resuming session — move to where you were when the session was interrupted."
        case .limited(.initializing):
            return "Initializing AR session."
        case .limited:
            return "Tracking limited - unspecified reason"
        }
    }
}

// MARK: - ARWorldMap Extension

extension ARWorldMap {
    var snapshotAnchor: SnapshotAnchor? {
        return anchors.compactMap { $0 as? SnapshotAnchor }.first
    }
}

// MARK: - UIViewController Extension for Alerts

extension UIViewController {
    /// Shows an alert with specified title, message, and button handler.
    func showAlert(title: String,
                   message: String,
                   buttonTitle: String = "OK",
                   showCancel: Bool = false,
                   buttonHandler: ((UIAlertAction) -> Void)? = nil) {
        print(title + "\n" + message)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: buttonHandler))
        if showCancel {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - CGImagePropertyOrientation Extension

extension CGImagePropertyOrientation {
    /// Initializes from device's camera orientation.
    init(cameraOrientation: UIDeviceOrientation) {
        switch cameraOrientation {
        case .portrait:
            self = .right
        case .portraitUpsideDown:
            self = .left
        case .landscapeLeft:
            self = .up
        case .landscapeRight:
            self = .down
        default:
            self = .right
        }
    }
}

// MARK: - ARView Extension for ARCoachingOverlayViewDelegate Conformance

extension ARView: @retroactive ARCoachingOverlayViewDelegate {
    
    // MARK: - Public Methods
    
    /// Adds AR coaching overlay to the AR view.
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(coachingOverlay)
    }
}

// MARK: - Color Extensions

let metallicBlue = Color(hex: "#4A90E2")
let metallicGreen = Color(hex: "#00A86B")

extension Color {
    /// Initializes a Color from a hex string.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
