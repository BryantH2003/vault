import SwiftUI

extension Font {
    static func figtree(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .black:
            return .custom("Figtree-Black", size: size)
        case .bold:
            return .custom("Figtree-Bold", size: size)
        case .heavy:
            return .custom("Figtree-ExtraBold", size: size)
        case .semibold:
            return .custom("Figtree-SemiBold", size: size)
        case .medium:
            return .custom("Figtree-Medium", size: size)
        case .light:
            return .custom("Figtree-Light", size: size)
        default:
            return .custom("Figtree-Regular", size: size)
        }
    }
}

// Convenience modifiers for Text views
extension View {
    func figtreeFont(_ size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.font(.figtree(size, weight: weight))
    }
} 