//
//  SnapshotAnchor.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import ARKit
import RealityKit

class SnapshotAnchor: ARAnchor {
    
    let imageData: Data
    
    // MARK: - Initialization
    
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
    
    init(imageData: Data, transform: float4x4) {
        self.imageData = imageData
        super.init(name: "snapshot", transform: transform)
    }
    
    required init(anchor: ARAnchor) {
        self.imageData = (anchor as! SnapshotAnchor).imageData
        super.init(anchor: anchor)
    }
    
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
