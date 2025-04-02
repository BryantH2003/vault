import SwiftUI

enum FontStyles {
    // MARK: - Title Styles
    static func largeTitle(_ text: Text) -> some View {
        text.figtreeFont(34, weight: .bold)
    }
    
    static func title1(_ text: Text) -> some View {
        text.figtreeFont(28, weight: .bold)
    }
    
    static func title2(_ text: Text) -> some View {
        text.figtreeFont(22, weight: .semibold)
    }
    
    static func title3(_ text: Text) -> some View {
        text.figtreeFont(20, weight: .semibold)
    }
    
    // MARK: - Body Styles
    static func bodyLarge(_ text: Text) -> some View {
        text.figtreeFont(17, weight: .regular)
    }
    
    static func bodyMedium(_ text: Text) -> some View {
        text.figtreeFont(15, weight: .regular)
    }
    
    static func bodySmall(_ text: Text) -> some View {
        text.figtreeFont(13, weight: .regular)
    }
    
    // MARK: - Button Styles
    static func buttonLarge(_ text: Text) -> some View {
        text.figtreeFont(17, weight: .semibold)
    }
    
    static func buttonMedium(_ text: Text) -> some View {
        text.figtreeFont(15, weight: .semibold)
    }
    
    static func buttonSmall(_ text: Text) -> some View {
        text.figtreeFont(13, weight: .semibold)
    }
    
    // MARK: - Label Styles
    static func label(_ text: Text) -> some View {
        text.figtreeFont(17, weight: .medium)
    }
    
    static func caption(_ text: Text) -> some View {
        text.figtreeFont(12, weight: .regular)
    }
}

// MARK: - View Modifiers
extension View {
    func largeTitleStyle() -> some View {
        modifier(FontStyleModifier(size: 34, weight: .bold))
    }
    
    func title1Style() -> some View {
        modifier(FontStyleModifier(size: 28, weight: .bold))
    }
    
    func title2Style() -> some View {
        modifier(FontStyleModifier(size: 22, weight: .semibold))
    }
    
    func title3Style() -> some View {
        modifier(FontStyleModifier(size: 20, weight: .semibold))
    }
    
    func bodyLargeStyle() -> some View {
        modifier(FontStyleModifier(size: 17, weight: .regular))
    }
    
    func bodyMediumStyle() -> some View {
        modifier(FontStyleModifier(size: 15, weight: .regular))
    }
    
    func bodySmallStyle() -> some View {
        modifier(FontStyleModifier(size: 13, weight: .regular))
    }
    
    func buttonLargeStyle() -> some View {
        modifier(FontStyleModifier(size: 17, weight: .semibold))
    }
    
    func buttonMediumStyle() -> some View {
        modifier(FontStyleModifier(size: 15, weight: .semibold))
    }
    
    func buttonSmallStyle() -> some View {
        modifier(FontStyleModifier(size: 13, weight: .semibold))
    }
    
    func labelStyle() -> some View {
        modifier(FontStyleModifier(size: 17, weight: .medium))
    }
    
    func captionStyle() -> some View {
        modifier(FontStyleModifier(size: 12, weight: .regular))
    }
}

// MARK: - Font Style Modifier
struct FontStyleModifier: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight
    
    func body(content: Content) -> some View {
        content.figtreeFont(size, weight: weight)
    }
} 