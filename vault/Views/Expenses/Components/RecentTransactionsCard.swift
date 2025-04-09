import SwiftUI

struct RecentTransactionsCard: View {
    let expenses: [Expense]
    let categories: [UUID: Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.headline)
                .foregroundColor(.primary)
            
            if expenses.isEmpty {
                Text("No recent transactions")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(expenses) { expense in
                        TransactionRow(
                            expense: expense,
                            category: categories[expense.categoryID]
                        )
                        
                        if expense.id != expenses.last?.id {
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

private struct TransactionRow: View {
    let expense: Expense
    let category: Category?
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(category?.fixedExpense == true ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: category?.fixedExpense == true ? "pin.fill" : "cart.fill")
                    .foregroundColor(category?.fixedExpense == true ? .blue : .orange)
            }
            
            // Expense Details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .fontWeight(.medium)
                
                HStack {
                    if let category = category {
                        Text(category.categoryName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let vendor = expense.vendor {
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
            
            // Amount and Date
            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.amount, format: .currency(code: "USD"))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(expense.transactionDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
} 
