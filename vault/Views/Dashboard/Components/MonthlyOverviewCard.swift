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
                OverviewSummaryRow(
                    title: "Income",
                    amount: totalIncome,
                    previousAmount: previousTotalIncome
                )
                
                OverviewSummaryRow(
                    title: "Expenses",
                    amount: totalExpenses,
                    previousAmount: previousTotalExpenses
                )
                
                OverviewSummaryRow(
                    title: "Savings",
                    amount: totalSavings,
                    previousAmount: previousTotalSavings
                )
                
            }
        }
        .padding()
    }
}
