import SwiftUI

struct ExpensesView: View {
    @StateObject private var viewModel = ExpensesViewModel()
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
                    MonthlyExpenseSummaryCard(
                        totalExpenses: viewModel.monthlyExpenses,
                        fixedExpenses: viewModel.monthlyFixedExpenses,
                        variableExpenses: viewModel.monthlyVariableExpenses
                    )
                    
                    if !viewModel.outstandingPayments.isEmpty || !viewModel.splitExpenses.isEmpty {
                        OutstandingPaymentsCard(
                            outstandingPayments: viewModel.outstandingPayments,
                            splitExpenses: viewModel.splitExpenses,
                            splitParticipants: viewModel.splitParticipants,
                            users: viewModel.users,
                            categories: viewModel.categories
                        )
                        .cardBackground()
                    }
                    
                    ExpenseCategoryBreakdownCard(
                        categories: viewModel.categories,
                        categoryExpenses: viewModel.categoryExpenses
                    )
                    
                    RecentTransactionsCard(
                        expenses: viewModel.recentExpenses,
                        categories: viewModel.categories
                    )
                    
                    FixedExpensesCard(
                        fixedExpenses: viewModel.fixedExpenses,
                        categories: viewModel.categories
                    )
                    
                    ForEach(viewModel.savingsGoals) { goal in
                        SavingsGoalCard(
                            goal: goal,
                            progress: goal.currentAmount / goal.targetAmount
                        )
                    }
                }
            }
            .padding()
        }
        .appBackground()
        .navigationTitle("Expenses")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.showingAddExpense = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddExpense, onDismiss: {
            // Refresh data when sheet is dismissed
            Task {
                await viewModel.loadExpensesData(forUserID: userID)
            }
        }) {
            AddExpenseView(userID: userID)
        }
        .task {
            print("ExpensesView task started - Loading data for user: \(userID)")
            await viewModel.loadExpensesData(forUserID: userID)
        }
        .refreshable {
            print("ExpensesView refresh triggered - Reloading data for user: \(userID)")
            await viewModel.loadExpensesData(forUserID: userID)
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
            Text("Error loading expenses")
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
