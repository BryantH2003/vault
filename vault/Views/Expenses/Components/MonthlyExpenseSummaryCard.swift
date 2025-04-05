import SwiftUI

struct MonthlyExpenseSummaryCard: View {
    let totalExpenses: Double
    let fixedExpenses: Double
    let variableExpenses: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Overview")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ExpenseSummaryRow(title: "Total Expenses", amount: totalExpenses, color: .red)
                ExpenseSummaryRow(title: "Fixed Expenses", amount: fixedExpenses, color: .blue)
                ExpenseSummaryRow(title: "Variable Expenses", amount: variableExpenses, color: .orange)
                
                Divider()
                
                // Show percentage of fixed vs variable
                HStack {
                    Text("Fixed/Variable Split")
                        .foregroundColor(.secondary)
                    Spacer()
                    if totalExpenses > 0 {
                        Text("\(Int((fixedExpenses/totalExpenses) * 100))% / \(Int((variableExpenses/totalExpenses) * 100))%")
                            .foregroundColor(.primary)
                            .fontWeight(.semibold)
                    } else {
                        Text("0% / 0%")
                            .foregroundColor(.primary)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

private struct ExpenseSummaryRow: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(amount, format: .currency(code: "USD"))
                .foregroundColor(color)
                .fontWeight(.semibold)
        }
    }
} 