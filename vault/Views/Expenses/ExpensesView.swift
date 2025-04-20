import SwiftUI

private enum ExpensesTab {
    case overview
    case outstandingPayments
    case myExpenses
    case mySavings
    
    var title: String {
        switch self {
        case .overview: return "Overview"
        case .myExpenses: return "Expenses"
        case .outstandingPayments: return "Outstanding"
        case .mySavings: return "Savings"
        }
    }
}

struct ExpensesView: View {
    @StateObject private var viewModel = ExpensesViewModel()
    @State private var showingMonthPicker = false
    @State private var selectedTab: ExpensesTab = .overview
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
                
                // Navigation tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach([ExpensesTab.overview, .outstandingPayments, .myExpenses, .mySavings], id: \.title) { tab in
                            Button(action: { selectedTab = tab }) {
                                VStack(spacing: 8) {
                                    Text(tab.title)
                                        .foregroundColor(selectedTab == tab ? .primary : .secondary)
                                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                                    
                                    Rectangle()
                                        .fill(selectedTab == tab ? Color.primary : Color.clear)
                                        .frame(height: 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.error {
                    ErrorView(error: error)
                } else {
                    switch selectedTab {
                    case .overview:
                        OverviewTabView(viewModel: viewModel)
                    case .myExpenses:
                        MyExpensesTabView(viewModel: viewModel)
                    case .outstandingPayments:
                        OutstandingPaymentsTabView(viewModel: viewModel, userID: userID)
                    case .mySavings:
                        MySavingsTabView(viewModel: viewModel)
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

// Tab Views
private struct OverviewTabView: View {
    let viewModel: ExpensesViewModel
    
    var body: some View {
        VStack(spacing: 16) {
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
        }
    }
}

private struct OutstandingPaymentsTabView: View {
    let viewModel: ExpensesViewModel
    let userID: UUID
    
    var body: some View {
        VStack(spacing: 16) {
            if !viewModel.outstandingPaymentsList.isEmpty {
                OutstandingPaymentsCard(
                    outstandingPayments: viewModel.outstandingPaymentsList,
                    users: viewModel.users,
                    categories: viewModel.categories
                )
                .cardBackground()
            }
            
            SplitExpensesOverviewCard(
                expensesYouOwe: viewModel.splitExpensesYouOweList,
                expensesOwedToYou: viewModel.splitExpensesOwedToYouList,
                participants: viewModel.splitParticipants,
                splitExpenses: viewModel.splitExpensesList,
                isLoading: viewModel.isLoadingPayments,
                users: viewModel.users,
                currentUserID: userID
            )
            .cardBackground()
            .environment(\.selectedDate, viewModel.selectedDate)
        }
    }
}

private struct MyExpensesTabView: View {
    let viewModel: ExpensesViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            FixedExpensesCard(
                fixedExpenses: viewModel.fixedExpensesList,
                categories: viewModel.categories
            )
            .cardBackground()
            
            RecentTransactionsCard(
                expenses: viewModel.recentExpensesList,
                categories: viewModel.categories,
                splitIDList: viewModel.splitIDList
            )
            .cardBackground()
        }
    }
}

private struct MySavingsTabView: View {
    let viewModel: ExpensesViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.savingsGoalsList) { goal in
                SavingsGoalCard(
                    goal: goal,
                    progress: goal.currentAmount / goal.targetAmount
                )
                .cardBackground()
            }
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
