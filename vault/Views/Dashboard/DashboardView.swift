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
                            .figtreeFont(.semibold, size: 20)
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
                        totalExpenses: viewModel.monthlyExpenses,
                        totalSavings: viewModel.monthlySavings,
                        totalIncome: viewModel.monthlyIncome,
                        previousTotalExpenses: viewModel.previousMonthExpenses,
                        previousTotalSavings: viewModel.previousMonthSavings,
                        previousTotalIncome: viewModel.previousMonthIncome
                    )
                    .cardBackground()
                    
                    if !$viewModel.splitExpensesYouOwe.isEmpty || !$viewModel.splitExpensesOwedToYou.isEmpty {
                        SplitExpensesOverviewCard(
                            expensesYouOwe: viewModel.splitExpensesYouOwe,
                            expensesOwedToYou: viewModel.splitExpensesOwedToYou,
                            participants: viewModel.splitParticipants,
                            users: viewModel.users,
                            currentUserID: userID
                        )
                        .cardBackground()
                    }
                    
                    RecentExpensesCard(
                        expenses: viewModel.recentExpenses,
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

struct MonthPickerView: View {
    @Binding var selectedDate: Date
    @Binding var showPicker: Bool
    @Environment(\.dismiss) private var dismiss
    
    // Available years (5 years back, 2 years forward)
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear-5)...(currentYear+2))
    }()
    
    // All months
    private let months = Calendar.current.monthSymbols
    
    // Selected components
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    init(selectedDate: Binding<Date>, showPicker: Binding<Bool>) {
        _selectedDate = selectedDate
        _showPicker = showPicker
        
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: selectedDate.wrappedValue))
        _selectedMonth = State(initialValue: calendar.component(.month, from: selectedDate.wrappedValue) - 1)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    // Month Picker
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(0..<months.count, id: \.self) { index in
                            Text(months[index])
                                .figtreeFont(.regular, size: 16)
                                .tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: UIScreen.main.bounds.width * 0.5)
                    
                    // Year Picker
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year))
                                .figtreeFont(.regular, size: 16)
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: UIScreen.main.bounds.width * 0.3)
                }
                .padding()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        updateSelectedDate()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func updateSelectedDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth + 1
        components.day = 1
        
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
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
