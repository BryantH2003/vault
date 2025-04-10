import SwiftUI

struct MonthlyExpenseSummaryCard: View {
    let totalExpenses: Double
    let fixedExpenses: Double
    let variableExpenses: Double
    let previousTotalExpenses: Double
    let previousTotalFixedExpenses: Double
    let previousTotalVariableExpenses: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Expenses")
                .cardTitleStyle()
            
            VStack(spacing: 12) {
                OverviewSummaryRow(
                    title: "Total Expenses",
                    amount: totalExpenses,
                    previousAmount: previousTotalExpenses
                )
                OverviewSummaryRow(
                    title: "Fixed Expenses",
                    amount: fixedExpenses,
                    previousAmount: previousTotalFixedExpenses
                )
                OverviewSummaryRow(
                    title: "Variable Expenses",
                    amount: variableExpenses,
                    previousAmount: previousTotalVariableExpenses
                )
                
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
    }
}

