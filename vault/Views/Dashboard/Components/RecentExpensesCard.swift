import SwiftUI

struct RecentExpensesCard: View {
    let expenses: [Expense]
    let categories: [UUID: Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Expenses")
                .cardTitleStyle()
            
            if expenses.isEmpty {
                Text("No recent expenses")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                    .figtreeFont(.regular, size: 16)
            } else {
                ForEach(expenses.prefix(5)) { expense in
                    ExpenseRow(expense: expense, category: categories[expense.categoryID])
                    
                    if expense.id != expenses.prefix(5).last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
    }
}

private struct ExpenseRow: View {
    let expense: Expense
    let category: Category?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .fontWeight(.medium)
                    .figtreeFont(.regular, size: 16)
                
                HStack {
                    if let category = category {
                        Text(category.categoryName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .figtreeFont(.regular, size: 16)
                    }
                    Text(expense.transactionDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .figtreeFont(.regular, size: 16)
                }
            }
            
            Spacer()
            
            Text(expense.amount, format: .currency(code: "USD"))
                .fontWeight(.semibold)
        }
    }
} 
