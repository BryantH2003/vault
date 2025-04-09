import SwiftUI

struct ExpenseCategoryBreakdownCard: View {
    let categories: [UUID: Category]
    let categoryExpenses: [UUID: Double]
    
    private var totalExpenses: Double {
        categoryExpenses.values.reduce(0, +)
    }
    
    private var sortedCategories: [(Category, Double)] {
        categoryExpenses.compactMap { (categoryID, amount) in
            guard let category = categories[categoryID] else { return nil }
            return (category, amount)
        }
        .sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .figtreeFont(.semibold, size: 18)
                .foregroundColor(.primary)
            
            if sortedCategories.isEmpty {
                Text("No expenses recorded")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(sortedCategories, id: \.0.id) { category, amount in
                        CategoryRow(
                            categoryName: category.categoryName,
                            amount: amount,
                            percentage: totalExpenses > 0 ? amount / totalExpenses : 0,
                            isFixed: category.fixedExpense
                        )
                        
                        if category.id != sortedCategories.last?.0.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .figtreeFont(.regular, size: 16)
    }
}

private struct CategoryRow: View {
    let categoryName: String
    let amount: Double
    let percentage: Double
    let isFixed: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(categoryName)
                    .fontWeight(.medium)
                if isFixed {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                Spacer()
                Text(amount, format: .currency(code: "USD"))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(isFixed ? Color.blue : Color.orange)
                        .frame(width: geometry.size.width * percentage, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            HStack {
                Spacer()
                Text("\(Int(percentage * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
} 
