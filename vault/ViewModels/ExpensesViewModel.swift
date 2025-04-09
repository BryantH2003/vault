import Foundation
import Combine

@MainActor
class ExpensesViewModel: ObservableObject {
    @Published var monthlyExpenses: Double = 0
    @Published var monthlyFixedExpenses: Double = 0
    @Published var monthlyVariableExpenses: Double = 0
    @Published var recentExpenses: [Expense] = []
    @Published var fixedExpenses: [Expense] = []
    @Published var categories: [UUID: Category] = [:]
    @Published var categoryExpenses: [UUID: Double] = [:]
    @Published var outstandingPayments: [OutstandingPayment] = []
    @Published var splitExpenses: [SplitExpense] = []
    @Published var splitParticipants: [UUID: [SplitExpenseParticipant]] = [:]
    @Published var users: [UUID: User] = [:]
    @Published var savingsGoals: [SavingsGoal] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showingAddExpense = false
    
    private let expenseService = ExpenseService.shared
    private let categoryService = CategoryService.shared
    private let outstandingService = OutstandingService.shared
    private let splitExpenseService = SplitExpenseService.shared
    private let splitExpenseParticipantService = SplitExpenseParticipantService.shared
    private let userService = UserService.shared
    private let savingsGoalService = SavingsGoalService.shared
    
    func loadExpensesData(forUserID userID: UUID) async {
        print("Starting to load expenses data for user: \(userID)")
        isLoading = true
        error = nil
        
        do {
            // Load categories first
            print("Fetching categories")
            let allCategories = try await categoryService.getAllCategories()
            categories = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
            print("Retrieved \(allCategories.count) categories")
            
            // Get current month's date range
            let currentDate = Date()
            let calendar = Calendar.current
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
            
            // Load monthly expenses
            print("Fetching expenses from \(startOfMonth) to \(endOfMonth)")
            let monthlyExpensesList = try await expenseService.getExpenses(forUserID: userID, in: startOfMonth...endOfMonth)
            
            // Calculate totals
            monthlyExpenses = monthlyExpensesList.reduce(0) { $0 + $1.amount }
            
            // Separate fixed and variable expenses
            let (fixed, variable) = monthlyExpensesList.reduce(into: ([Expense](), [Expense]())) { result, expense in
                if let category = categories[expense.categoryID], category.fixedExpense {
                    result.0.append(expense)
                } else {
                    result.1.append(expense)
                }
            }
            
            fixedExpenses = fixed.sorted(by: { $0.transactionDate > $1.transactionDate })
            monthlyFixedExpenses = fixed.reduce(0) { $0 + $1.amount }
            monthlyVariableExpenses = variable.reduce(0) { $0 + $1.amount }
            
            // Calculate category totals
            categoryExpenses = Dictionary(grouping: monthlyExpensesList, by: { $0.categoryID })
                .mapValues { expenses in expenses.reduce(0) { $0 + $1.amount } }
            
            // Get recent expenses
            recentExpenses = Array(monthlyExpensesList
                .sorted(by: { $0.transactionDate > $1.transactionDate })
                .prefix(5))
            
            // Load outstanding payments
            print("Loading outstanding payments")
            outstandingPayments = try await outstandingService.getOutstandingPayments(forUserID: userID)
            
            // Load split expenses
            print("Loading split expenses")
            splitExpenses = try await splitExpenseService.getUnpaidSplitExpenses(userID: userID)
            
            // Load split expense participants
            for expense in splitExpenses {
                let participants = try await splitExpenseParticipantService.getUnpaidParticipants(forExpenseID: expense.id)
                splitParticipants[expense.id] = participants
            }
            
            // Load users for split expenses
            let userIDs = Set(splitExpenses.map { $0.payerID } + splitParticipants.values.flatMap { $0.map { $0.userID } })
            for userID in userIDs {
                if let user = try await userService.getUser(id: userID) {
                    users[userID] = user
                }
            }
            
            // Load savings goals
            print("Loading savings goals")
            savingsGoals = try await savingsGoalService.getSavingsGoals(forUserID: userID)
            
            print("Data loading completed successfully")
            print("Monthly total: \(monthlyExpenses)")
            print("Fixed expenses: \(monthlyFixedExpenses)")
            print("Variable expenses: \(monthlyVariableExpenses)")
            print("Recent expenses count: \(recentExpenses.count)")
            print("Categories with expenses: \(categoryExpenses.count)")
            
        } catch {
            print("Error loading expenses data: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
    }
} 
