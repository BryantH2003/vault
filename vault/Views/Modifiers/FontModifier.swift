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

struct LargeNumberStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .figtreeFont(.semibold, size: 20)
            .foregroundColor(.black)
    }
}

struct SecondaryTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .figtreeFont(.regular, size: 14)
            .foregroundColor(.secondary)
    }
}

struct CardRowTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .figtreeFont(.medium, size: 16)
            .foregroundColor(.primary)
    }
}

struct CardRowAmountStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .figtreeFont(.semibold, size: 16)
            .foregroundColor(.primary)
    }
}

struct FriendDetailPaidByTagStyle: ViewModifier {
    var textColor: Color
    
    func body(content: Content) -> some View {
        content
            .figtreeFont(.regular, size: 14)
            .foregroundColor(textColor)
    }
}

struct SplitExpenseStatusTagsStyle: ViewModifier {
    var status: String
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending":
            return .orange
        case "paid":
            return .green
        case "declined":
            return .red
        default:
            return .gray
        }
    }
    
    func body(content: Content) -> some View {
        content
            .figtreeFont(.regular, size: 14)
            .foregroundColor(statusColor(for: status))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(for: status).opacity(0.2))
            .cornerRadius(8)
    }
}

struct ExpenseTypeTagStyle: ViewModifier {
    var expenseType: String
    
    private func expenseTypeColor(for expenseType: String) -> Color {
        switch expenseType.lowercased() {
        case "split":
            return .blue
        default:
            return .gray
        }
    }
    func body(content: Content) -> some View {
        content
            .figtreeFont(.regular, size: 14)
            .foregroundColor(expenseTypeColor(for: expenseType))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(expenseTypeColor(for: expenseType).opacity(0.2))
            .cornerRadius(8)
    }
}

extension View {
    func figtreeFont(_ font: FigtreeFont, size: CGFloat) -> some View {
        modifier(FigtreeTextStyle(font: font, size: size))
    }
    
    func cardTitleStyle() -> some View {
        modifier(CardTitleStyle())
    }
    
    func largeNumberStyle() -> some View {
        modifier(LargeNumberStyle())
    }
    
    func secondaryTitleStyle() -> some View {
        modifier(SecondaryTitleStyle())
    }
    
    func cardRowTitleStyle() -> some View {
        modifier(CardRowTitleStyle())
    }
    
    func cardRowAmountStyle() -> some View {
        modifier(CardRowAmountStyle())
    }
    
    func friendDetailPaidByTagStyle(textColor: Color) -> some View {
        modifier(FriendDetailPaidByTagStyle(textColor: textColor))
    }
    
    func splitExpenseStatusTagsStyle(status: String) -> some View {
        modifier(SplitExpenseStatusTagsStyle(status: status))
    }
    
    func expenseTypeTagStyle(expenseType: String) -> some View {
        modifier(ExpenseTypeTagStyle(expenseType: expenseType))
    }
}
