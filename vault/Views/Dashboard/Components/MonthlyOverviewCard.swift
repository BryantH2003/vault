import SwiftUI

struct MonthlyOverviewCard: View {
    let monthlyIncome: Double
    let monthlyExpenses: Double
    let monthlySavings: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Overview")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                OverviewRow(title: "Income", amount: monthlyIncome, color: .green)
                OverviewRow(title: "Expenses", amount: monthlyExpenses, color: .red)
                OverviewRow(title: "Savings", amount: monthlySavings, color: .blue)
                
                Divider()
                
                OverviewRow(
                    title: "Net",
                    amount: monthlyIncome - monthlyExpenses,
                    color: monthlyIncome - monthlyExpenses >= 0 ? .green : .red
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

private struct OverviewRow: View {
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