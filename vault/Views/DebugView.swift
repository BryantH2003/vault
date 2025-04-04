import SwiftUI

struct DebugView: View {
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    private let databaseService = CoreDataService.shared
    private let debugDatabaseService = DebugService.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Database Operations")) {
                    Button(action: clearDatabase) {
                        Label("Clear Database", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: populateDatabase) {
                        Label("Populate with Dummy Data", systemImage: "plus.circle")
                    }
                }
                
                Section(header: Text("Database Statistics")) {
                    NavigationLink(destination: DatabaseStatsView()) {
                        Label("View Database Statistics", systemImage: "chart.bar")
                    }
                }
            }
            .navigationTitle("Debug Tools")
            .alert("Debug Operation", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private func clearDatabase() {
        isLoading = true
        
        Task {
            do {
                // Clear all entities
                try await debugDatabaseService.clearDatabase()
                alertMessage = "Database cleared successfully"
                showingAlert = true
            } catch {
                alertMessage = "Error clearing database: \(error.localizedDescription)"
                showingAlert = true
            }
            
            isLoading = false
        }
    }
    
    private func populateDatabase() {
        isLoading = true
        
        Task {
            do {
                // Create dummy data
                let user = try await createDummyUser()
                let categories = try await createDummyCategories()
                let expenses = try await createDummyExpenses(for: user.id, categories: categories)
                let incomes = try await createDummyIncomes(for: user.id)
                let budgets = try await createDummyBudgets(for: user.id, categories: categories)
                let savingsGoals = try await createDummySavingsGoals(for: user.id)
                
                alertMessage = """
                    Database populated with:
                    - 1 user
                    - \(categories.count) categories
                    - \(expenses.count) expenses
                    - \(incomes.count) incomes
                    - \(budgets.count) budgets
                    - \(savingsGoals.count) savings goals
                    """
                showingAlert = true
            } catch {
                alertMessage = "Error populating database: \(error.localizedDescription)"
                showingAlert = true
            }
            
            isLoading = false
        }
    }
    
    private func createDummyUser() async throws -> User {
        let user = User(
            username: "testuser",
            email: "test@example.com",
            passwordHash: "dummyhash",
            fullName: "Test User",
            employmentStatus: "Employed",
            netPaycheckIncome: 5000.0,
            profileImageUrl: "",
            monthlyIncome: 5000.0,
            monthlySavingsGoal: 2000,
            monthlySpendingLimit: 3000,
            friends: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        return try await databaseService.createUser(user)
    }
    
    private func createDummyCategories() async throws -> [Category] {
        let categoryNames = ["Food", "Transportation", "Entertainment", "Bills", "Shopping"]
        var categories: [Category] = []
        
        for name in categoryNames {
            let category = Category(
                categoryName: name,
                fixedExpense: name == "Bills"
            )
            let createdCategory = try await databaseService.createCategory(category)
            categories.append(createdCategory)
        }
        
        return categories
    }
    
    private func createDummyExpenses(for userID: UUID, categories: [Category]) async throws -> [Expense] {
        var expenses: [Expense] = []
        let vendors = ["Walmart", "Amazon", "Netflix", "Uber", "Restaurant"]
        
        for _ in 0..<10 {
            let randomCategory = categories.randomElement()!
            let expense = Expense(
                userID: userID,
                categoryID: randomCategory.id,
                title: "Random Expense",
                amount: Double.random(in: 10...200),
                vendor: vendors.randomElement()!
            )
            let createdExpense = try await databaseService.createExpense(expense)
            expenses.append(createdExpense)
        }
        
        return expenses
    }
    
    private func createDummyIncomes(for userID: UUID) async throws -> [Income] {
        var incomes: [Income] = []
        let sources = ["Salary", "Freelance", "Investment", "Gift"]
        
        for _ in 0..<3 {
            let income = Income(
                userID: userID,
                source: sources.randomElement()!,
                description: "Monthly \(sources.randomElement()!) Income",
                amount: Double.random(in: 1000...5000)
            )
            let createdIncome = try await databaseService.createIncome(income)
            incomes.append(createdIncome)
        }
        
        return incomes
    }
    
    private func createDummyBudgets(for userID: UUID, categories: [Category]) async throws -> [Budget] {
        var budgets: [Budget] = []
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        for category in categories {
            let budget = Budget(
                userID: userID,
                categoryID: category.id,
                title: "\(category.categoryName) Budget",
                budgetAmount: Double.random(in: 200...1000),
                startDate: startDate,
                endDate: endDate
            )
            let createdBudget = try await databaseService.createBudget(budget)
            budgets.append(createdBudget)
        }
        
        return budgets
    }
    
    private func createDummySavingsGoals(for userID: UUID) async throws -> [SavingsGoal] {
        var savingsGoals: [SavingsGoal] = []
        let goals = [
            ("Emergency Fund", 10000.0),
            ("Vacation", 5000.0),
            ("New Car", 20000.0)
        ]
        
        for (name, target) in goals {
            let savingsGoal = SavingsGoal(
                userID: userID,
                goalName: name,
                targetAmount: target,
                currentAmount: Double.random(in: 0...target),
                targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())
            )
            let createdGoal = try await databaseService.createSavingsGoal(savingsGoal)
            savingsGoals.append(createdGoal)
        }
        
        return savingsGoals
    }
}

struct DatabaseStatsView: View {
    @State private var stats: [String: Int] = [:]
    @State private var isLoading = true
    
    private let databaseService = CoreDataService.shared
    
    var body: some View {
        List {
            ForEach(Array(stats.keys.sorted()), id: \.self) { key in
                HStack {
                    Text(key)
                    Spacer()
                    Text("\(stats[key] ?? 0)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Database Statistics")
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        Task {
            do {
                let users = try await databaseService.getAllUsers()
                let expenses = try await databaseService.getAllExpenses()
                let incomes = try await databaseService.getAllIncomes()
                let categories = try await databaseService.getCategories()
                let budgets = try await databaseService.getAllBudgets()
                let savingsGoals = try await databaseService.getAllSavingsGoals()
                
                stats = [
                    "Users": users.count,
                    "Expenses": expenses.count,
                    "Incomes": incomes.count,
                    "Categories": categories.count,
                    "Budgets": budgets.count,
                    "Savings Goals": savingsGoals.count
                ]
                
                isLoading = false
            } catch {
                print("Error loading stats: \(error)")
                isLoading = false
            }
        }
    }
}

#Preview {
    DebugView()
} 
