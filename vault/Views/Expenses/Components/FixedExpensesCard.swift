import SwiftUI

struct FixedExpensesCard: View {
    let fixedExpenses: [Expense]
    let categories: [UUID: Category]
    
    private var totalFixedExpenses: Double {
        fixedExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Fixed Expenses")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(totalFixedExpenses, format: .currency(code: "USD"))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            if fixedExpenses.isEmpty {
                Text("No fixed expenses")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(fixedExpenses) { expense in
                        FixedExpenseRow(
                            expense: expense,
                            category: categories[expense.categoryID]
                        )
                        
                        if expense.id != fixedExpenses.last?.id {
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

private struct FixedExpenseRow: View {
    let expense: Expense
    let category: Category?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .fontWeight(.medium)
                
                HStack {
                    if let category = category {
                        Text(category.categoryName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let vendor = expense.vendor, !vendor.isEmpty {
                        if category != nil {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(vendor)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.amount, format: .currency(code: "USD"))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Monthly")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
} 
