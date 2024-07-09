//
//  SaveLoadButton.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import SwiftUI

struct SaveLoadButton: View {
    @EnvironmentObject var saveLoadState: SaveLoadState

    var body: some View {
        HStack {
            if !saveLoadState.loadButton.isHidden {
                Button(action: {
                    saveLoadState.loadButton.isPressed = true
                }) {
                    Text("Load Experience")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                }
                .background(metallicBlue)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!saveLoadState.loadButton.isEnabled)
            }
            
            Button(action: {
                saveLoadState.saveButton.isPressed = true
            }) {
                Text("Save Experience")
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                
            }
            .background(saveLoadState.saveButton.isEnabled ? metallicBlue : Color.gray)
            .font(.system(size: 15))
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(!saveLoadState.saveButton.isEnabled)
        }
    }
}

struct SaveLoadButton_Previews: PreviewProvider {
    static var previews: some View {
        SaveLoadButton()
            .environmentObject(SaveLoadState())
    }
}
