import SwiftUI

// 扩展Color以支持十六进制颜色值
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// 应用主题
struct AppTheme {
    // 颜色主题
    struct Colors {
        static let primary = Color(hex: "#24d265")
        static let secondary = Color(hex: "#778b78")
        static let tertiary = Color(hex: "#618d95")
        static let error = Color(hex: "#ff4a42")
        static let neutral = Color(hex: "#262323")
        static let neutralVariant = Color(hex: "#80887e")
        
        // Logo主题色
        static let themeYellow = Color(hex: "#F4D03F")  // 主要芒果黄
        static let themeYellowLight = Color(hex: "#FCF3A1")  // 浅芒果黄
        static let themeYellowDark = Color(hex: "#E8B428")   // 深芒果黄
        static let themeAccent = Color(hex: "#FFF5B3")   // 芒果强调色
    }
}

// 为SwiftUI视图提供主题扩展
extension View {
    func withAppTheme() -> some View {
        self
            .accentColor(AppTheme.Colors.primary)
            // 可以添加其他全局主题设置
    }
} 
