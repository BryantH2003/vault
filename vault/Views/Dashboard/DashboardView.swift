import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: DashboardViewModel
    
    init(databaseService: DatabaseService, userId: String) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(databaseService: databaseService, userId: userId))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MonthYearSelectorView(viewModel: viewModel)
                MonthlyOverviewSection(viewModel: viewModel)
                OutstandingPaymentsSection(viewModel: viewModel)
                RecentExpensesSection(viewModel: viewModel)
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: ProfileButton())
        .task {
            await viewModel.loadMonthlyOverview()
        }
        .onChange(of: viewModel.selectedDate) { newDate in
            Task {
                await viewModel.loadMonthlyOverview()
            }
        }
    }
}

// MARK: - Month Year Selector
private struct MonthYearSelectorView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        Button(action: { viewModel.showingDatePicker.toggle() }) {
            Text(viewModel.selectedDate.formatted(.dateTime.month(.wide).year()))
                .title1Style()
                .foregroundColor(.primary)
                .padding(.vertical, 10)
        }
        .sheet(isPresented: $viewModel.showingDatePicker) {
            MonthYearPickerView(selectedDate: $viewModel.selectedDate, isPresented: $viewModel.showingDatePicker)
                .presentationDetents([.height(300)])
        }
    }
}

// MARK: - Monthly Overview Section
private struct MonthlyOverviewSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Monthly Overview")
                .bodyMediumStyle()
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(6)
                .padding(.leading)
            
            VStack(spacing: 12) {
                // Combined Spending Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Spending")
                        .bodyMediumStyle()
                        .foregroundColor(.primary)
                        .padding(.horizontal, 0)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .cornerRadius(6)
                        .padding(.leading, 4)
                    
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.spent.formatted(.currency(code: "USD")))
                                .title2Style()
                                .foregroundColor(.primary)
                            
                            Text("Left to spend")
                                .captionStyle()
                                .foregroundColor(.secondary)
                            
                            Text((4000 - viewModel.spent).formatted(.currency(code: "USD")))
                                .bodyMediumStyle()
                                .foregroundColor(secondaryAmountColor(for: 4000 - viewModel.spent))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            let percentageChange = calculatePercentageChange(current: viewModel.spent, previous: viewModel.previousSpent)
                            let isIncrease = percentageChange >= 0
                            
                            HStack(alignment: .center, spacing: 4) {
                                Image(systemName: isIncrease ? "arrow.up.right" : "arrow.down.right")
                                    .foregroundColor(isIncrease ? .red : .green)
                                
                                Text(String(format: "%.1f%%", abs(percentageChange)))
                                    .bodyMediumStyle()
                                    .foregroundColor(isIncrease ? .red : .green)
                            }
                            
                            Text("Difference")
                                .captionStyle()
                                .foregroundColor(.secondary)
                            
                            Text((viewModel.spent - viewModel.previousSpent).formatted(.currency(code: "USD")))
                                .bodyMediumStyle()
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.blue.opacity(0.65), lineWidth: 1)
                )
                
                // Combined Savings Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Savings")
                        .bodyMediumStyle()
                        .foregroundColor(.primary)
                        .padding(.horizontal, 0)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .cornerRadius(6)
                        .padding(.leading, 4)
                    
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.saved.formatted(.currency(code: "USD")))
                                .title2Style()
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            let percentageChange = calculatePercentageChange(current: viewModel.saved, previous: viewModel.previousSaved)
                            let isIncrease = percentageChange >= 0
                            
                            HStack(alignment: .center, spacing: 4) {
                                Image(systemName: isIncrease ? "arrow.up.right" : "arrow.down.right")
                                    .foregroundColor(isIncrease ? .green : .red)
                                
                                Text(String(format: "%.1f%%", abs(percentageChange)))
                                    .bodyMediumStyle()
                                    .foregroundColor(isIncrease ? .green : .red)
                            }
                            
                            Text("Difference")
                                .captionStyle()
                                .foregroundColor(.secondary)
                            
                            Text((viewModel.saved - viewModel.previousSaved).formatted(.currency(code: "USD")))
                                .bodyMediumStyle()
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.blue.opacity(0.65), lineWidth: 1)
                )
            }
        }
        .padding()
        .background(Color.blue.opacity(0.15))
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    private func calculatePercentageChange(current: Double, previous: Double) -> Double {
        guard previous != 0 else { return 0 }
        return ((current - previous) / previous) * 100
    }
    
    private func secondaryAmountColor(for amount: Double) -> Color {
        if amount < 0 {
            return .red
        } else if amount < 500 {
            return .yellow
        } else {
            return .secondary
        }
    }
}

// MARK: - Outstanding Payments Section
private struct OutstandingPaymentsSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    
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
                    ForEach(viewModel.outstandingPayments) { payment in
                        OutstandingPaymentCard(payment: payment)
                    }
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.15))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

// MARK: - Recent Expenses Section
private struct RecentExpensesSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    
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
        .padding(.horizontal)
    }
}

struct SpendingCard: View {
    let title: String
    let mainAmount: Double
    let subtitle: String
    let secondaryAmount: Double
    let color: Color
    
    private var secondaryAmountColor: Color {
        if secondaryAmount < 0 {
            return .red
        } else if secondaryAmount < 500 {
            return .yellow
        } else {
            return .secondary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .bodyMediumStyle()
                .foregroundColor(.primary)
                .padding(.horizontal, 0)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(6)
                .padding(.leading, 4)
            
            Text(mainAmount.formatted(.currency(code: "USD")))
                .title2Style()
                .foregroundColor(.primary)
            
            Text(subtitle)
                .captionStyle()
                .foregroundColor(.secondary)
            
            Text(secondaryAmount.formatted(.currency(code: "USD")))
                .bodyMediumStyle()
                .foregroundColor(secondaryAmountColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color, lineWidth: 1)
        )
    }
}

struct MonthlyChangeCard: View {
    let currentAmount: Double
    let previousAmount: Double
    let color: Color
    
    var percentageChange: Double {
        guard previousAmount != 0 else { return 0 }
        return ((currentAmount - previousAmount) / previousAmount) * 100
    }
    
    var amountChange: Double {
        currentAmount - previousAmount
    }
    
    var isIncrease: Bool {
        percentageChange >= 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monthly Change")
                .bodyMediumStyle()
                .foregroundColor(.primary)
                .padding(.horizontal, 0)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(6)
                .padding(.leading, 4)
            
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: isIncrease ? "arrow.up.right" : "arrow.down.right")
                    .foregroundColor(isIncrease ? .red : .green)
                
                Text(String(format: "%.1f%%", abs(percentageChange)))
                    .title2Style()
                    .foregroundColor(isIncrease ? .red : .green)
            }
            
            Text("Difference")
                .captionStyle()
                .foregroundColor(.secondary)
            
            Text(amountChange.formatted(.currency(code: "USD")))
                .bodyMediumStyle()
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color, lineWidth: 1)
        )
    }
}

struct MonthYearPickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    private let months = Calendar.current.monthSymbols
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear-5)...(currentYear+5))
    }()
    
    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>) {
        _selectedDate = selectedDate
        _isPresented = isPresented
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: selectedDate.wrappedValue))
        _selectedMonth = State(initialValue: calendar.component(.month, from: selectedDate.wrappedValue) - 1)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    // Month Picker
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(0..<months.count, id: \.self) { index in
                            Text(months[index])
                                .bodyLargeStyle()
                                .tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    // Year Picker
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year))
                                .bodyLargeStyle()
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding()
                
                Button("Done") {
                    let calendar = Calendar.current
                    var components = DateComponents()
                    components.year = selectedYear
                    components.month = selectedMonth + 1
                    components.day = 1
                    
                    if let date = calendar.date(from: components) {
                        selectedDate = date
                    }
                    isPresented = false
                }
                .buttonLargeStyle()
                .foregroundColor(.blue)
            }
            .navigationTitle("Select Month and Year")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DashboardCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .labelStyle()
                .foregroundColor(.secondary)
            
            Text(amount.formatted(.currency(code: "USD")))
                .title1Style()
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }
}

struct SavingsCard: View {
    let title: String
    let mainAmount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .bodyMediumStyle()
                .foregroundColor(.primary)
                .padding(.horizontal, 0)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(6)
                .padding(.leading, 4)
            
            Text(mainAmount.formatted(.currency(code: "USD")))
                .title2Style()
                .foregroundColor(.primary)
            
            // Add spacer to maintain same height as other cards
            Spacer()
                .frame(height: 44)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color, lineWidth: 1)
        )
    }
}

struct PaymentProgressCard: View {
    let title: String
    let totalAmount: Double
    let paidAmount: Double
    let dueDate: Date?
    let color: Color
    
    private var progressPercentage: Double {
        guard totalAmount > 0 else { return 0 }
        return min((paidAmount / totalAmount) * 100, 100)
    }
    
    private var progressColor: Color {
        if progressPercentage >= 100 {
            return .green
        } else if progressPercentage >= 25 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 4) {
                Text(title)
                    .bodyMediumStyle()
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(paidAmount.formatted(.currency(code: "USD")))
                    .bodySmallStyle()
                    .foregroundColor(.secondary)
                
                Text("/")
                    .bodySmallStyle()
                    .foregroundColor(.secondary)
                
                Text(totalAmount.formatted(.currency(code: "USD")))
                    .bodyMediumStyle()
                    .foregroundColor(.primary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 4)
                        .opacity(0.2)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(progressPercentage) * geometry.size.width / 100, geometry.size.width), height: 4)
                        .foregroundColor(progressColor)
                }
            }
            .frame(height: 4)
            
            HStack {
                Text(String(format: "%.0f%%", progressPercentage))
                    .captionStyle()
                    .foregroundColor(progressColor)
                
                Spacer()
                
                if let dueDate = dueDate {
                    Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .captionStyle()
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color, lineWidth: 1)
        )
    }
}

struct MonthlyOverviewCard: View {
    let title: String
    let amount: Double
    let previousAmount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .bodyMediumStyle()
                .foregroundColor(.primary)
                .padding(.horizontal, 0)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(6)
                .padding(.leading, 4)
            
            Text(amount.formatted(.currency(code: "USD")))
                .title2Style()
                .foregroundColor(.primary)
            
            Text("Difference")
                .captionStyle()
                .foregroundColor(.secondary)
            
            Text((amount - previousAmount).formatted(.currency(code: "USD")))
                .bodyMediumStyle()
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color, lineWidth: 1)
        )
    }
}

struct OutstandingPaymentCard: View {
    let payment: OutstandingPayment
    
    private var progressColor: Color {
        if payment.percentageCompleted >= 100 {
            return .green
        } else if payment.percentageCompleted >= 75 {
            return .blue
        } else if payment.percentageCompleted >= 50 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 4) {
                Text(payment.title)
                    .bodyMediumStyle()
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(payment.totalAmount.formatted(.currency(code: "USD")))
                    .bodySmallStyle()
                    .foregroundColor(.secondary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 4)
                        .opacity(0.2)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(payment.percentageCompleted) * geometry.size.width / 100, geometry.size.width), height: 4)
                        .foregroundColor(progressColor)
                }
            }
            .frame(height: 4)
            
            HStack {
                Text(String(format: "%.0f%%", payment.percentageCompleted))
                    .captionStyle()
                    .foregroundColor(progressColor)
                
                Spacer()
                
                if let dueDate = payment.dueDate {
                    Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .captionStyle()
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.purple.opacity(0.65), lineWidth: 1)
        )
    }
}

struct RecentExpenseCard: View {
    let expense: Expense
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 4) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.description)
                        .bodyMediumStyle()
                        .foregroundColor(.primary)
                    
                    Text(expense.category)
                        .captionStyle()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(expense.amount.formatted(.currency(code: "USD")))
                        .bodyMediumStyle()
                        .foregroundColor(.primary)
                    
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                        .captionStyle()
                        .foregroundColor(.secondary)
                }
            }
            
            if expense.isRecurring {
                HStack(spacing: 4) {
                    Image(systemName: "repeat")
                        .font(.caption)
                    Text(expense.recurringInterval ?? "")
                        .captionStyle()
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        DashboardView(databaseService: DatabaseService(), userId: "user123")
            .environmentObject(AuthViewModel())
    }
} 
