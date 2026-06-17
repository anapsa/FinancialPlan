import SwiftUI

enum Theme {
    static let accent = Color.indigo

    static func color(for bucket: BudgetBucket) -> Color {
        switch bucket {
        case .needs:     return .blue
        case .lifestyle: return .orange
        case .reserve:   return .green
        case .goals:     return .purple
        }
    }

    enum Spacing {
        static let tight: CGFloat = 8
        static let regular: CGFloat = 16
        static let loose: CGFloat = 24
    }

    static let cornerRadius: CGFloat = 16
}

extension Color {
    init(hex: String) {
        let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        self.init(.sRGB,
                  red: Double((value >> 16) & 0xFF) / 255,
                  green: Double((value >> 8) & 0xFF) / 255,
                  blue: Double(value & 0xFF) / 255,
                  opacity: 1)
    }
}
