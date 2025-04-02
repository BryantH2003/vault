import SwiftUI
import FirebaseFirestore

struct DebugView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var databaseService = DatabaseService()
    @State private var expenses: [Expense] = []
    @State private var savings: [Savings] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var isPopulatingData = false
    @State private var isResettingDatabase = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Authentication State") {
                    Text("Is Authenticated: \(authViewModel.isAuthenticated ? "Yes" : "No")")
                    if let user = authViewModel.user {
                        Text("User ID: \(user.id ?? "No ID")")
                        Text("Email: \(user.email)")
                        Text("Name: \(user.fullName)")
                    } else {
                        Text("No user logged in")
                    }
                }
                
                Section("Database Actions") {
                    Button(action: {
                        resetAndPopulateDatabase()
                    }) {
                        HStack {
                            if isResettingDatabase {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Text("Reset & Populate Database")
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .disabled(!authViewModel.isAuthenticated || isResettingDatabase)
                }
                
                Section("Populate Data") {
                    Button(action: {
                        Task {
                            await populateDummyData()
                        }
                    }) {
                        HStack {
                            if isPopulatingData {
                                ProgressView()
                            } else {
                                Text("Populate Dummy Data")
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .disabled(isPopulatingData || !authViewModel.isAuthenticated)
                    .opacity(authViewModel.isAuthenticated ? 1 : 0.5)
                }
                
                Section("User Settings") {
                    if let user = authViewModel.user {
                        Text("Monthly Income: $\(user.monthlyIncome, specifier: "%.2f")")
                        Text("Monthly Savings Goal: $\(user.monthlySavingsGoal, specifier: "%.2f")")
                        Text("Monthly Spending Limit: $\(user.monthlySpendingLimit, specifier: "%.2f")")
                    } else {
                        Text("No user settings available")
                    }
                }
                
                Section("Recent Expenses") {
                    if isLoading {
                        ProgressView()
                    } else if let error = error {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    } else if expenses.isEmpty {
                        Text("No expenses found")
                    } else {
                        ForEach(expenses) { expense in
                            VStack(alignment: .leading) {
                                Text(expense.description)
                                    .font(.headline)
                                Text("$\(expense.amount, specifier: "%.2f")")
                                    .font(.subheadline)
                                Text(expense.date.formatted())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("Recent Savings") {
                    if isLoading {
                        ProgressView()
                    } else if let error = error {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    } else if savings.isEmpty {
                        Text("No savings found")
                    } else {
                        ForEach(savings) { saving in
                            VStack(alignment: .leading) {
                                Text("Monthly Savings")
                                    .font(.headline)
                                Text("$\(saving.amount, specifier: "%.2f")")
                                    .font(.subheadline)
                                Text("Month: \(saving.month)/\(saving.year)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Debug Data")
            .task {
                await loadData()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadData() async {
        guard let userId = authViewModel.user?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            let calendar = Calendar.current
            let currentDate = Date()
            let components = calendar.dateComponents([.year, .month], from: currentDate)
            let year = components.year ?? calendar.component(.year, from: currentDate)
            let month = components.month ?? calendar.component(.month, from: currentDate)
            
            // Get current month's expenses
            async let expensesTask = databaseService.getExpenses(
                for: userId,
                in: currentDate.startOfMonth...currentDate.endOfMonth
            )
            
            // Get current month's savings
            async let savingsTask = databaseService.getSavings(
                for: userId,
                month: month,
                year: year
            )
            
            let (expensesResult, savingsResult) = try await (expensesTask, savingsTask)
            
            self.expenses = expensesResult
            if let savings = savingsResult {
                self.savings = [savings]
            } else {
                self.savings = []
            }
        } catch {
            self.error = error
            print("Error loading data: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    private func populateDummyData() async {
        guard let userId = authViewModel.user?.id else { return }
        
        isPopulatingData = true
        error = nil
        
        do {
            try await databaseService.populateDummyData(for: userId)
            await loadData() // Reload the data after populating
        } catch {
            self.error = error
        }
        
        isPopulatingData = false
    }
    
    private func resetAndPopulateDatabase() {
        isResettingDatabase = true
        
        Task {
            do {
                try await authViewModel.resetAndPopulateDatabase()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isResettingDatabase = false
        }
    }
} 