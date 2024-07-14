//
//  SnapshotAnchor.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import ARKit
import RealityKit

/// Represents an AR anchor that stores the snapshot of the saved session for reference.
class SnapshotAnchor: ARAnchor {
    
    /// The JPEG representation of the captured image data.
    let imageData: Data
    
    // MARK: - Initialization
    
    /// Creates a new snapshot anchor capturing the current view.
    /// - Parameter view: The ARView from which to capture the image.
    convenience init?(capturing view: ARView) {
        guard let frame = view.session.currentFrame else { return nil }
        
        let image = CIImage(cvPixelBuffer: frame.capturedImage)
        let orientation = CGImagePropertyOrientation(cameraOrientation: UIDevice.current.orientation)
        
        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let data = context.jpegRepresentation(of: image.oriented(orientation),
                                                    colorSpace: CGColorSpaceCreateDeviceRGB(),
                                                    options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.7])
        else { return nil }
        
        self.init(imageData: data, transform: frame.camera.transform)
    }
    
    /// Initializes a new snapshot anchor with the provided image data and transform.
    /// - Parameters:
    ///   - imageData: The image data to be stored.
    ///   - transform: The transformation matrix for the anchor's position.
    init(imageData: Data, transform: float4x4) {
        self.imageData = imageData
        super.init(name: "snapshot", transform: transform)
    }
    
    required init(anchor: ARAnchor) {
        self.imageData = (anchor as! SnapshotAnchor).imageData
        super.init(anchor: anchor)
    }
    
    // MARK: - Secure Coding
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let snapshot = aDecoder.decodeObject(forKey: "snapshot") as? Data else {
            return nil
        }
        self.imageData = snapshot
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(imageData, forKey: "snapshot")
    }
}
