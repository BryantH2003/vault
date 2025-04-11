import SwiftUI

struct ExpensesView: View {
    @StateObject private var viewModel = ExpensesViewModel()
    @State private var showingMonthPicker = false
    let userID: UUID
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Month selector button
                Button(action: { showingMonthPicker = true }) {
                    HStack {
                        Text(Date.monthYearString(from: viewModel.selectedDate))
                            .cardTitleStyle()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.primary)
                    .padding(.vertical, 8)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.error {
                    ErrorView(error: error)
                } else {
                    MonthlyExpenseSummaryCard(
                        totalExpenses: viewModel.monthlyExpensesTotal,
                        fixedExpenses: viewModel.monthlyFixedExpensesTotal,
                        variableExpenses: viewModel.monthlyVariableExpensesTotal,
                        previousTotalExpenses: viewModel.previousMonthExpensesTotal,
                        previousTotalFixedExpenses: viewModel.previousMonthFixedExpensesTotal,
                        previousTotalVariableExpenses: viewModel.previousMonthVariableExpensesTotal
                    )
                    .cardBackground()
                    
                    ExpenseCategoryBreakdownCard(
                        categories: viewModel.categories,
                        categoryExpenses: viewModel.categoryExpenses,
                        previousMonthCategoryExpenses: viewModel.previousMonthCategoryExpenses
                    )
                    .cardBackground()
                    
                    FixedExpensesCard(
                        fixedExpenses: viewModel.fixedExpensesList,
                        categories: viewModel.categories
                    )
                    .cardBackground()
                    
                    if !viewModel.outstandingPaymentsList.isEmpty || !viewModel.splitExpensesList.isEmpty {
                        OutstandingPaymentsCard(
                            outstandingPayments: viewModel.outstandingPaymentsList,
                            splitExpenses: viewModel.splitExpensesList,
                            splitParticipants: viewModel.splitParticipants,
                            users: viewModel.users,
                            categories: viewModel.categories
                        )
                        .cardBackground()
                    }
                    
                    RecentTransactionsCard(
                        expenses: viewModel.recentExpensesList,
                        categories: viewModel.categories
                    )
                    
                    ForEach(viewModel.savingsGoalsList) { goal in
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
        .sheet(isPresented: $showingMonthPicker) {
            MonthPickerView(selectedDate: $viewModel.selectedDate, showPicker: $showingMonthPicker)
                .presentationDetents([.height(300)])
        }
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
