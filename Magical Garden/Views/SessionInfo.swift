//
//  SessionInfo.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import SwiftUI

struct SessionInfo: View {
    var label: String?
    
    var body: some View {
        if let text = label {
            VStack {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(metallicBlue.opacity(0.4))
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .shadow(radius: 5)
            }
        }
    }
}
