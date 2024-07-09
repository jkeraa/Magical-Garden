//
//  SnapshotThumbnail.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import UIKit
import SwiftUI

struct SnapshotThumbnail: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .background(Color.gray.opacity(0.5))
            .cornerRadius(12)
    }
}

struct SnapshotThumbnail_Previews: PreviewProvider {
    static var image = UIImage(named: "AppIcon")!
    static var previews: some View {
        SnapshotThumbnail(image: image)
    }
}
