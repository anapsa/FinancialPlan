import Foundation

enum Format {
    static func currency(_ value: Double, decimals: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"
    }

    static func compactCurrency(_ value: Double) -> String {
        switch abs(value) {
        case 1_000_000...:
            return "R$ \(trimmed(value / 1_000_000)) mi"
        case 1_000...:
            return "R$ \(trimmed(value / 1_000)) mil"
        default:
            return currency(value)
        }
    }

    static func percent(_ fraction: Double, decimals: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: fraction)) ?? "0%"
    }

    private static func trimmed(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        return rounded == rounded.rounded()
            ? String(format: "%.0f", rounded)
            : String(format: "%.1f", rounded).replacingOccurrences(of: ".", with: ",")
    }
}
