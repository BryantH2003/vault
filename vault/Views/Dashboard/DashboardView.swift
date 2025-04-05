import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    let userID: UUID
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.error {
                    ErrorView(error: error)
                } else {
                    MonthlyOverviewCard(
                        monthlyIncome: viewModel.monthlyIncome,
                        monthlyExpenses: viewModel.monthlyExpenses,
                        monthlySavings: viewModel.monthlySavings
                    )
                    
                    RecentExpensesCard(
                        expenses: viewModel.recentExpenses,
                        categories: viewModel.categories
                    )
                    
                    ForEach(viewModel.savingsGoals) { goal in
                        SavingsGoalCard(
                            goal: goal,
                            progress: goal.currentAmount / goal.targetAmount
                        )
                    }
                    
                    if !viewModel.outstandingSplitExpenses.isEmpty {
                        OutstandingPaymentsCard(
                            splitExpenses: viewModel.outstandingSplitExpenses,
                            participants: viewModel.splitExpenseParticipants,
                            users: viewModel.users
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .task {
            print("DashboardView task started - Loading data for user: \(userID)")
            await viewModel.loadDashboardData(forUserID: userID)
        }
        .refreshable {
            print("DashboardView refresh triggered - Reloading data for user: \(userID)")
            await viewModel.loadDashboardData(forUserID: userID)
        }
    }
}

private struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error loading dashboard")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 