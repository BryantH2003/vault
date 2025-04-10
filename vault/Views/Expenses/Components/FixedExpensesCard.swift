import SwiftUI

struct FixedExpensesCard: View {
    let fixedExpenses: [FixedExpense]
    let categories: [UUID: Category]
    
    private var totalFixedExpenses: Double {
        fixedExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Fixed Expenses")
                    .cardTitleStyle()
                
                Spacer()
                
                Text(totalFixedExpenses, format: .currency(code: "USD"))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            if fixedExpenses.isEmpty {
                Text("No fixed expenses")
                    .secondaryTitleStyle()
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
    let expense: FixedExpense
    let category: Category?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .cardRowTitleStyle()
                
                HStack {
                    if let category = category {
                        Text(category.categoryName)
                            .secondaryTitleStyle()
                    }
                    
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.amount, format: .currency(code: "USD"))
                    .cardRowAmountStyle()
                
                Text(expense.recurringFrequency)
                    .figtreeFont(.regular, size: 14)
                    .foregroundColor(.blue)
            }
        }
    }
} 
