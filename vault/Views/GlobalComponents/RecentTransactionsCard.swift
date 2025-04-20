import SwiftUI

struct RecentTransactionsCard: View {
    let expenses: [Expense]
    let categories: [UUID: Category]
    let splitIDList: [UUID]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .cardTitleStyle()
            
            if expenses.isEmpty {
                
                // TODO: Add Button "Start Tracking Expenses!"
                Text("No recent transactions")
                    .secondaryTitleStyle()
                
            } else {
                VStack(spacing: 12) {
                    ForEach(expenses) { expense in
                        TransactionRow(
                            expense: expense,
                            category: categories[expense.categoryID],
                            isSplitExpense: splitIDList.contains(expense.id)
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
    let isSplitExpense: Bool
    
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
                    .cardRowTitleStyle()
                
                HStack {
                    if let category = category {
                        Text(category.categoryName)
                            .secondaryTitleStyle()
                    }
                    
                    if let vendor = expense.vendor {
                        if category != nil {
                            Text("•")
                                .secondaryTitleStyle()
                        }
                        Text(vendor)
                            .secondaryTitleStyle()
                    }
                }
                
                if isSplitExpense {
                    Text("Split")
                        .expenseTypeTagStyle(expenseType: "split")
                }
            }
            
            Spacer()
            
            // Amount and Date
            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.amount, format: .currency(code: "USD"))
                    .cardRowAmountStyle()
                
                Text(expense.transactionDate, style: .date)
                    .secondaryTitleStyle()
            }
        }
    }
} 
