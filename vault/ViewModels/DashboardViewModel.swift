import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var monthlyIncome: Double = 0
    @Published var monthlyExpenses: Double = 0
    @Published var monthlySavings: Double = 0
    @Published var recentExpenses: [Expense] = []
    @Published var categories: [UUID: Category] = [:]
    @Published var savingsGoals: [SavingsGoal] = []
    @Published var outstandingSplitExpenses: [SplitExpense] = []
    @Published var splitExpenseParticipants: [UUID: [SplitExpenseParticipant]] = [:]
    @Published var users: [UUID: User] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    
    private let expenseService = ExpenseService.shared
    private let incomeService = IncomeService.shared
    private let categoryService = CategoryService.shared
    private let savingsGoalService = SavingsGoalService.shared
    private let splitExpenseService = SplitExpenseService.shared
    private let splitExpenseParticipantService = SplitExpenseParticipantService.shared
    private let userService = UserService.shared
    
    func loadDashboardData(forUserID userID: UUID) async {
        print("Starting to load dashboard data for user: \(userID)")
        isLoading = true
        error = nil
        
        do {
            // Load monthly income
            let currentDate = Date()
            let calendar = Calendar.current
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
            
            print("Fetching incomes from \(startOfMonth) to \(endOfMonth)")
            let incomes = try await incomeService.getIncomes(forUserID: userID, in: startOfMonth...endOfMonth)
            print("Retrieved \(incomes.count) incomes")
            monthlyIncome = incomes.reduce(0) { $0 + $1.amount }
            print("Total monthly income: \(monthlyIncome)")
            
            // Load monthly expenses
            print("Fetching expenses")
            let expenses = try await expenseService.getExpenses(forUserID: userID, in: startOfMonth...endOfMonth)
            print("Retrieved \(expenses.count) expenses")
            monthlyExpenses = expenses.reduce(0) { $0 + $1.amount }
            print("Total monthly expenses: \(monthlyExpenses)")
            
            // Calculate monthly savings
            monthlySavings = monthlyIncome - monthlyExpenses
            print("Calculated monthly savings: \(monthlySavings)")
            
            // Load recent expenses
            recentExpenses = Array(expenses.sorted(by: { $0.transactionDate > $1.transactionDate }).prefix(5))
            print("Loaded \(recentExpenses.count) recent expenses")
            
            // Load categories
            print("Fetching categories")
            let allCategories = try await categoryService.getAllCategories()
            print("Retrieved \(allCategories.count) categories")
            categories = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
            
            // Load savings goals
            print("Fetching savings goals")
            savingsGoals = try await savingsGoalService.getActiveSavingsGoals(forUserID: userID)
            print("Retrieved \(savingsGoals.count) savings goals")
            
            // Load outstanding split expenses
            print("Fetching outstanding split expenses")
            outstandingSplitExpenses = try await splitExpenseService.getUnpaidSplitExpenses(userID: userID)
            print("Retrieved \(outstandingSplitExpenses.count) outstanding split expenses")
            
            // Load split expense participants
            for expense in outstandingSplitExpenses {
                print("Fetching participants for split expense: \(expense.id)")
                let participants = try await splitExpenseParticipantService.getUnpaidParticipants(forExpenseID: expense.id)
                print("Retrieved \(participants.count) participants for expense \(expense.id)")
                splitExpenseParticipants[expense.id] = participants
                
                // Load user details for participants
                for participant in participants {
                    if users[participant.userID] == nil {
                        print("Fetching user details for participant: \(participant.userID)")
                        if let user = try await userService.getUser(id: participant.userID) {
                            users[participant.userID] = user
                            print("Retrieved user details for \(user.username)")
                        }
                    }
                }
            }
        } catch {
            print("Error loading dashboard data: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
        print("Finished loading dashboard data")
    }
} 
