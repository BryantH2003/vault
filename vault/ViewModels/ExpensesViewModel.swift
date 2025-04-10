import Foundation
import Combine

@MainActor
class ExpensesViewModel: ObservableObject {
    @Published var monthlyIncome: Double = 0
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
    
    // Previous month data
    @Published var previousMonthIncome: Double = 0
    @Published var previousMonthExpenses: Double = 0
    @Published var previousMonthFixedExpenses: Double = 0
    @Published var previousMonthVariableExpenses: Double = 0
    @Published var previousMonthSavings: Double = 0
    
    @Published var selectedDate: Date = Date() {
        didSet {
            if let currentUserID = currentUserID {
                Task {
                    await loadExpensesData(forUserID: currentUserID)
                }
            }
        }
    }
    
    private var currentUserID: UUID?
    
    private let expenseService = ExpenseService.shared
    private let incomeService = IncomeService.shared
    private let categoryService = CategoryService.shared
    private let outstandingService = OutstandingService.shared
    private let splitExpenseService = SplitExpenseService.shared
    private let splitExpenseParticipantService = SplitExpenseParticipantService.shared
    private let userService = UserService.shared
    private let savingsGoalService = SavingsGoalService.shared
    
    func loadExpensesData(forUserID userID: UUID) async {
        isLoading = true
        error = nil
        currentUserID = userID
        
        do {
            // --- Monthly Overview Card Data ---
            
            // Get date range for selected month
            let startDate = selectedDate.startOfMonth()
            let endDate = selectedDate.endOfMonth()
            
            // Get date range for previous month
            let calendar = Calendar.current
            guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: selectedDate),
                  let previousStartDate = calendar.date(from: calendar.dateComponents([.year, .month], from: previousMonthDate)),
                  let previousEndDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: previousStartDate) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error calculating previous month dates"])
            }
            
            print("Loading data for month: \(Date.monthYearString(from: selectedDate))")
            print("Date range: \(startDate) to \(endDate)")
            
            // Load categories first as they're referenced by expenses
            print("Loading categories")
            let allCategories = try await categoryService.getAllCategories()
            categories = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
            
            // Load monthly expenses
            print("Loading monthly expenses")
            let monthlyExpensesList = try await expenseService.getExpenses(forUserID: userID, in: startDate...endDate)
            monthlyExpenses = monthlyExpensesList.reduce(0) { $0 + $1.amount }
            
            // Calculate fixed and variable expenses
            let (fixed, variable) = monthlyExpensesList.reduce(into: (0.0, 0.0)) { result, expense in
                if let category = categories[expense.categoryID], category.fixedExpense {
                    result.0 += expense.amount
                } else {
                    result.1 += expense.amount
                }
            }
            monthlyFixedExpenses = fixed
            monthlyVariableExpenses = variable
            
            // Load previous month expenses
            print("Loading previous month expenses")
            let previousExpensesList = try await expenseService.getExpenses(forUserID: userID, in: previousStartDate...previousEndDate)
            previousMonthExpenses = previousExpensesList.reduce(0) { $0 + $1.amount }
            
            // Calculate fixed and variable expenses for previous month
            let (prevFixed, prevVariable) = previousExpensesList.reduce(into: (0.0, 0.0)) { result, expense in
                if let category = categories[expense.categoryID], category.fixedExpense {
                    result.0 += expense.amount
                } else {
                    result.1 += expense.amount
                }
            }
            
            previousMonthFixedExpenses = prevFixed
            previousMonthVariableExpenses = prevVariable
            print("Previous Month Expenses Calculated:", previousMonthFixedExpenses, previousMonthVariableExpenses)
            
            // Load current month income
            print("Loading current month income")
            let monthlyIncomeList = try await incomeService.getIncomes(forUserID: userID, in: startDate...endDate)
            monthlyIncome = monthlyIncomeList.reduce(0) { $0 + $1.amount }
            
            // Load previous month income
            print("Loading previous month income")
            let previousIncomeList = try await incomeService.getIncomes(forUserID: userID, in: previousStartDate...previousEndDate)
            previousMonthIncome = previousIncomeList.reduce(0) { $0 + $1.amount }
            
            previousMonthSavings = previousMonthIncome - previousMonthExpenses
            
            // Get fixed expenses for the month
            fixedExpenses = monthlyExpensesList.filter { expense in
                categories[expense.categoryID]?.fixedExpense == true
            }
            
            // Calculate category expenses
            categoryExpenses = Dictionary(grouping: monthlyExpensesList, by: { $0.categoryID })
                .mapValues { expenses in expenses.reduce(0) { $0 + $1.amount } }
            
            // Get recent expenses for the month
            recentExpenses = Array(monthlyExpensesList
                .sorted(by: { $0.transactionDate > $1.transactionDate }))
            
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
