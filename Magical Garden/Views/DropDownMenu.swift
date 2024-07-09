import SwiftUI

struct DropDownMenu: View {
    let options: [String]
    
    var menuWidth: CGFloat = 230
    var buttonHeight: CGFloat = 40
    var maxItemsDisplayed: Int = 3
    
    @Binding var selectedOptionIndex: Int
    @Binding var showDropdown: Bool
    
    @EnvironmentObject var sessionSettings: SessionSettings
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation {
                        showDropdown.toggle()
                    }
                }, label: {
                    HStack {
                        Text(options[selectedOptionIndex])
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                    }
                })
                .padding(.horizontal, 20)
                .frame(width: menuWidth, height: buttonHeight, alignment: .leading)
                
                // Selection menu
                if showDropdown {
                    let scrollViewHeight: CGFloat = CGFloat(min(options.count, maxItemsDisplayed)) * buttonHeight
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(options.indices, id: \.self) { index in
                                Button(action: {
                                    selectOption(index)
                                    withAnimation {
                                        showDropdown.toggle()
                                    }
                                }, label: {
                                    HStack {
                                        Text(options[index])
                                        Spacer()
                                        if index == selectedOptionIndex {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                })
                                .padding(.horizontal, 20)
                                .frame(width: menuWidth, height: buttonHeight, alignment: .leading)
                            }
                        }
                    }
                    .frame(height: scrollViewHeight)
                }
            }
            .foregroundStyle(Color.white)
            .background(RoundedRectangle(cornerRadius: 16).fill(metallicBlue))
        }
        .frame(width: menuWidth, height: buttonHeight, alignment: .top)
        .zIndex(100)
    }
    
    private func selectOption(_ index: Int) {
        selectedOptionIndex = index
        updateSessionSettings(index: index)
    }
    
    private func updateSessionSettings(index: Int) {
        switch index {
        case 0:
            sessionSettings.isPlacingModeEnabled = true
            sessionSettings.isEditModeEnabled = false
            sessionSettings.isInteractModeEnabled = false
            sessionSettings.isHelpDebugEnabled = true
        case 1:
            sessionSettings.isEditModeEnabled = true
            sessionSettings.isPlacingModeEnabled = false
            sessionSettings.isInteractModeEnabled = false
            sessionSettings.isHelpDebugEnabled = false
        case 2:
            sessionSettings.isInteractModeEnabled = true
            sessionSettings.isEditModeEnabled = false
            sessionSettings.isPlacingModeEnabled = false
            sessionSettings.isHelpDebugEnabled = false
        default:
            break
        }
    }
}

extension Color {
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

let metallicBlue = Color(hex: "#4A90E2")
let metallicGreen = Color(hex: "#00A86B")
