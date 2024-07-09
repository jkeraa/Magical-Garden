//
//  SettingsView.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 07/07/24.
//

import SwiftUI
import AVFoundation

enum Setting {
    case peopleOcclusion
    case objectOcclusion
    case helpDebug
    case postProcess
    
    var label: String {
        switch self {
        case .peopleOcclusion:
            return "Occlusion"
        case .objectOcclusion:
            return "Occlusion"
        case .helpDebug:
            return "UI Help"
        case .postProcess:
            return "Post Process"
        }
    }
    
    var systemName: String {
        switch self {
        case .peopleOcclusion:
            return "person"
        case .objectOcclusion:
            return "cube.box.fill"
        case .helpDebug:
            return "character.duployan"
        case .postProcess:
            return "camera.filters"
        }
    }
}

struct SettingsGrid : View {
    @EnvironmentObject var sessionSettings: SessionSettings
    private var gridItemLayout = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 25)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 25) {
                SettingToggleButton(setting: .peopleOcclusion, isOn: $sessionSettings.isPeopleOcclusionEnabled)
                
                SettingToggleButton(setting: .objectOcclusion, isOn: $sessionSettings.isObjectOcclusionEnabled)
                
                SettingToggleButton(setting: .helpDebug, isOn: $sessionSettings.isHelpDebugEnabled)
                
                SettingToggleButton(setting: .postProcess, isOn: $sessionSettings.isPostProcessEnabled)
            }
            .padding(.top, 35)
        }
    }
}

struct SettingToggleButton : View {
    let setting: Setting
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            // Handle button action here
            self.isOn.toggle()
            
            // Example: Play sound effect
            SoundManager.shared.playSoundEffect(fileName: "SFX_6", fileType: "wav")
            
            // Example: Provide haptic feedback
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
