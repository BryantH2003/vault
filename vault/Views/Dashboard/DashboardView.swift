import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
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
                    MonthlyOverviewCard(
                        totalExpenses: viewModel.monthlyExpensesTotal,
                        totalSavings: viewModel.monthlySavingsTotal,
                        totalIncome: viewModel.monthlyIncomeTotal,
                        previousTotalExpenses: viewModel.previousMonthExpensesTotal,
                        previousTotalSavings: viewModel.previousMonthSavingsTotal,
                        previousTotalIncome: viewModel.previousMonthIncomeTotal
                    )
                    .cardBackground()
                    
                    if !$viewModel.splitExpensesYouOweList.isEmpty || !$viewModel.splitExpensesOwedToYouList.isEmpty {
                        SplitExpensesOverviewCard(
                            expensesYouOwe: viewModel.splitExpensesYouOweList,
                            expensesOwedToYou: viewModel.splitExpensesOwedToYouList,
                            participants: viewModel.splitParticipants,
                            users: viewModel.users,
                            currentUserID: userID
                        )
                        .cardBackground()
                    }
                    
                    RecentTransactionsCard(
                        expenses: viewModel.recentExpensesList,
                        categories: viewModel.categories
                    )
                    .cardBackground()
                }
            }
            .padding()
        }
        .appBackground()
        .sheet(isPresented: $showingMonthPicker) {
            MonthPickerView(selectedDate: $viewModel.selectedDate, showPicker: $showingMonthPicker)
                .presentationDetents([.height(300)])
        }
        .onChange(of: viewModel.selectedDate) { _ in
            Task {
                await viewModel.loadDashboardData(forUserID: userID)
            }
        }
        .task {
            print("DashboardView task started - Loading data for user: \(userID)")
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
            Text("Error loading data")
                .figtreeFont(.semibold, size: 16)
            Text(error.localizedDescription)
                .figtreeFont(.regular, size: 14)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 
