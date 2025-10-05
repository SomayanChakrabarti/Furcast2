import SwiftUI
import UIKit

// MARK: - Color Contrast Utilities
extension Color {
    /// Returns black or white text color for optimal contrast against this background color
    func contrastingTextColor() -> Color {
        // Convert to UIColor to access RGB components
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate relative luminance using WCAG formula
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        // Return custom dark gray for light backgrounds, white for dark backgrounds
        return luminance > 0.5 ? Color(uiColor: UIColor(displayP3Red: 60/255, green: 60/255, blue: 60/255, alpha: 1)) : .white
    }
} 