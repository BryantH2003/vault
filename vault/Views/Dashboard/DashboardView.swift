import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: DashboardViewModel
    @State private var showingDatePicker = false
    
    init(databaseService: DatabaseService, userId: String) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(databaseService: databaseService, userId: userId))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with Date Picker
                Button(action: { showingDatePicker = true }) {
                    Text(viewModel.selectedDate.formatted(.dateTime.month(.wide).year()))
                        .title2Style()
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                
                // Monthly Overview Section
                MonthlyOverviewSection(viewModel: viewModel.monthlyOverviewViewModel)
                    .padding(.horizontal)
                
                // Outstanding Payments Section
                OutstandingPaymentsSection(viewModel: viewModel.outstandingPaymentsViewModel)
                    .padding(.horizontal)
                
                // Recent Expenses Section
                RecentExpensesSection(viewModel: viewModel.recentExpensesViewModel)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: ProfileButton())
        .sheet(isPresented: $showingDatePicker) {
            MonthYearPickerView(selectedDate: $viewModel.selectedDate, isPresented: $showingDatePicker)
                .presentationDetents([.height(300)])
        }
        .onChange(of: viewModel.selectedDate) { newDate in
            viewModel.updateDate(newDate)
        }
        .task {
            viewModel.loadDashboardData()
        }
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

#Preview {
    NavigationView {
        DashboardView(databaseService: DatabaseService(), userId: "user123")
            .environmentObject(AuthViewModel())
    }
} 
