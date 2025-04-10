import SwiftUI

extension Color {
    static let primaryBlue = Color(hex: "3A86FF")
    static let secondaryPurple = Color(hex: "8338EC")
    static let accentGreen = Color(hex: "06D6A0")
    static let accentRed = Color(hex: "EF476F")
    static let darkBackground = Color(hex: "121212")
    static let cardBackground = Color(hex: "1E1E1E")
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    
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
            (a, r, g, b) = (1, 1, 1, 0)
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

