import UIKit

class ColorManager {
    static let shared = ColorManager() // Singleton instance

    private init() {}

    func backgroundColor() -> UIColor {
        return UIColor(hex: "#fff7f3")
    }
    
    func nightRiderColor() -> UIColor {
        return UIColor(hex: "#332e2e")
    }

    func teaGreenColor() -> UIColor {
        return UIColor(hex: "#d9ffb6")
    }
    
    func pigPinkColor() -> UIColor {
        return UIColor(hex: "#ffd3f3")
    }
    
    func clearDayColor() -> UIColor {
        return UIColor(hex: "#e3fff8")
    }
    
    func plusButtonTintColor() -> UIColor {
        return UIColor.white
    }

    // Add more color methods as needed
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
