import SwiftUI

struct MonthlyOverviewSection: View {
    @ObservedObject var viewModel: MonthlyOverviewViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Overview")
                .bodyMediumStyle()
                .foregroundColor(.primary)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let error = viewModel.error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .padding()
            } else if let overview = viewModel.monthlyOverview {
                VStack(spacing: 12) {
                    // Spending Card
                    OverviewCard(
                        title: "Spending",
                        amount: overview.spent,
                        previousAmount: overview.previousSpent,
                        color: .red,
                        leftToSpend: 4000 - overview.spent
                    )
                    
                    // Savings Card
                    OverviewCard(
                        title: "Savings",
                        amount: overview.saved,
                        previousAmount: overview.previousSaved,
                        color: .green,
                        leftToSpend: nil
                    )
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.15))
        .cornerRadius(20)
    }
}

struct OutstandingPaymentsSection: View {
    @ObservedObject var viewModel: OutstandingPaymentsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Outstanding Payments")
                .bodyMediumStyle()
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(6)
                .padding(.leading)
            
            VStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .bodyMediumStyle()
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.outstandingPayments.isEmpty {
                    Text("No outstanding payments")
                        .bodyLargeStyle()
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    // Change from horizontal ScrollView to vertical VStack
                    ForEach(viewModel.outstandingPayments) { payment in
                        OutstandingPaymentCard(payment: payment)
                            .padding(.horizontal) // Add padding for better spacing
                    }
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.15))
        .cornerRadius(20)
    }
}

struct RecentExpensesSection: View {
    @ObservedObject var viewModel: RecentExpensesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Expenses")
                .bodyMediumStyle()
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(6)
                .padding(.leading)
            
            VStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .bodyMediumStyle()
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.recentExpenses.isEmpty {
                    Text("No recent expenses")
                        .bodyLargeStyle()
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(viewModel.recentExpenses) { expense in
                        RecentExpenseCard(expense: expense, color: .green.opacity(0.65))
                    }
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.15))
        .cornerRadius(20)
    }
}
