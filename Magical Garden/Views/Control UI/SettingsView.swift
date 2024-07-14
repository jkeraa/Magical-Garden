//
//  SettingsView.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 07/07/24.
//

import SwiftUI
import AVFoundation

/// The main settings view containing the settings grid.
struct SettingsView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        NavigationView {
            SettingsGrid()
                .navigationBarTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                    Button(action: {
                        self.showSettings.toggle()
                    }) {
                        Text("Done").bold()
                    }
                )
        }
    }
}
/// Enum representing different application settings.
enum Setting {
    case peopleOcclusion
    case objectOcclusion
    case sound
    case postProcess
    
    /// Returns the display label for each setting.
    var label: String {
        switch self {
        case .peopleOcclusion:
            return "Occlusion"
        case .objectOcclusion:
            return "Occlusion"
        case .sound:
            return "Sound"
        case .postProcess:
            return "Post Process"
        }
    }
    
    /// Returns the system image name for the setting icon.
    var systemName: String {
        switch self {
        case .peopleOcclusion:
            return "person"
        case .objectOcclusion:
            return "cube.box.fill"
        case .sound:
            return "music.quarternote.3"
        case .postProcess:
            return "camera.filters"
        }
    }
}

/// Displays the grid of setting toggle buttons.
struct SettingsGrid: View {
    @EnvironmentObject var sessionSettings: SessionSettings
    private var gridItemLayout = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 25)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 25) {
                SettingToggleButton(setting: .peopleOcclusion, isOn: $sessionSettings.isPeopleOcclusionEnabled)
                
                SettingToggleButton(setting: .objectOcclusion, isOn: $sessionSettings.isObjectOcclusionEnabled)
                
                SettingToggleButton(setting: .sound, isOn: $sessionSettings.isSoundEnabled)
                
                SettingToggleButton(setting: .postProcess, isOn: $sessionSettings.isPostProcessEnabled)
            }
            .padding(.top, 35)
        }
    }
}

/// Toggle button for a specific setting.
struct SettingToggleButton: View {
    let setting: Setting
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            self.isOn.toggle()
            SoundManager.shared.playSoundEffect(fileName: "SFX_6", fileType: "wav")
            HapticFeedbackManager.shared.generateSelectionFeedback()
        }) {
            VStack {
                Image(systemName: setting.systemName)
                    .font(.system(size: 35))
                    .foregroundColor(self.isOn ? .green : .secondary)
                
                Text(setting.label)
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(self.isOn ? Color(UIColor.label) : .secondary)
                    .padding(.top, 5)
            }
        }
        .frame(width: 100, height: 100)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20.0)
    }
}
