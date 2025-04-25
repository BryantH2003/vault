import SwiftUI

struct AnalyticsBarDetails: View {
    let data: BarData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(data.period)
                .font(.headline)
            
            VStack(spacing: 8) {
                DetailRow(title: "Income", amount: data.income, color: DataType.income.color)
                DetailRow(title: "Expenses", amount: data.expenses, color: DataType.expenses.color)
                DetailRow(title: "Savings", amount: data.savings, color: DataType.savings.color)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct DetailRow: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
            Spacer()
            Text(amount, format: .currency(code: "USD"))
                .fontWeight(.medium)
        }
    }
} 