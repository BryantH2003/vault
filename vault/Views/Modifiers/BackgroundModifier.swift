import SwiftUI

struct AppBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(hex: "fcf8ec"))
    }
}

struct CardBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "309ad2"), lineWidth: 2)
            )
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackgroundStyle())
    }
    
    func cardBackground() -> some View {
        modifier(CardBackgroundStyle())
    }
} 
