import SwiftUI

struct MonthlyOverviewCard: View {
    let totalExpenses: Double
    let totalSavings: Double
    let totalIncome: Double
    let previousTotalExpenses: Double
    let previousTotalSavings: Double
    let previousTotalIncome: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Overview")
                .cardTitleStyle()
            
            VStack(spacing: 12) {
                ExpenseSummaryRow(
                    title: "Income",
                    amount: totalIncome,
                    previousAmount: previousTotalIncome
                )
                
                ExpenseSummaryRow(
                    title: "Expenses",
                    amount: totalExpenses,
                    previousAmount: previousTotalExpenses
                )
                
                ExpenseSummaryRow(
                    title: "Savings",
                    amount: totalSavings,
                    previousAmount: previousTotalSavings
                )
                
            }
        }
        .padding()
    }
}

private struct ExpenseSummaryRow: View {
    let title: String
    let amount: Double
    let previousAmount: Double
    
    private var percentageChange: Double {
        guard previousAmount != 0 else { return 0 }
        return ((amount - previousAmount) / previousAmount) * 100
    }
    
    private var difference: Double {
        amount - previousAmount
    }
    
    var body: some View {
        HStack {
            // Left side - Current amount
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .figtreeFont(.regular, size: 14)
                    .foregroundColor(.secondary)
                Text(amount, format: .currency(code: "USD"))
                    .figtreeFont(.medium, size: 16)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // Right side - Comparison
            VStack(alignment: .trailing, spacing: 4) {
                // Percentage change
                HStack(spacing: 4) {
                    if difference == 0 || percentageChange == 0 {
                        Text(String(format: "%.1f%%", abs(percentageChange)))
                    } else {
                        Image(systemName: difference > 0 ? "arrow.up.right" : "arrow.down.right")
                        
                        if title == "Expenses" {
                            Text(String(format: "%.1f%%", abs(percentageChange)))
                                .foregroundColor(difference > 0 ? .red : .green)
                        } else {
                            Text(String(format: "%.1f%%", abs(percentageChange)))
                                .foregroundColor(difference > 0 ? .green : .red)
                        }
                        
                    }
                }
                .figtreeFont(.medium, size: 14)
                
                // Actual difference
                Text(difference >= 0 ? "+\(difference, format: .currency(code: "USD"))" : "\(difference, format: .currency(code: "USD"))")
                    .figtreeFont(.medium, size: 12)
                    .foregroundColor(.secondary)
            }
        }
    }
} 
