import SwiftUI

enum FigtreeFont {
    case regular
    case medium
    case semibold
    case bold
    
    var name: String {
        switch self {
        case .regular: return "Figtree-Regular"
        case .medium: return "Figtree-Medium"
        case .semibold: return "Figtree-SemiBold"
        case .bold: return "Figtree-Bold"
        }
    }
}

struct FigtreeTextStyle: ViewModifier {
    let font: FigtreeFont
    let size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.custom(font.name, size: size))
    }
}

struct CardTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .figtreeFont(.semibold, size: 18)
            .foregroundColor(.primary)
            .overlay(
                Rectangle().fill(Color(hex: "90c33c")).frame(height: 3).offset(y: 4)
                , alignment: .bottom
            )
    }
}

extension View {
    func figtreeFont(_ font: FigtreeFont, size: CGFloat) -> some View {
        modifier(FigtreeTextStyle(font: font, size: size))
    }
    
    func cardTitleStyle() -> some View {
        modifier(CardTitleStyle())
    }
}
