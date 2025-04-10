import Foundation
import Combine

@MainActor
class ExpensesViewModel: ObservableObject {
    @Published var monthlyIncomeTotal: Double = 0
    @Published var monthlyExpensesTotal: Double = 0
    @Published var monthlyFixedExpensesTotal: Double = 0
    @Published var monthlyVariableExpensesTotal: Double = 0
    @Published var recentExpensesList: [Expense] = []
    @Published var fixedExpensesList: [FixedExpense] = []
    @Published var categories: [UUID: Category] = [:]
    @Published var categoryExpenses: [UUID: Double] = [:]
    @Published var outstandingPaymentsList: [OutstandingPayment] = []
    @Published var splitExpensesList: [SplitExpense] = []
    @Published var splitParticipants: [UUID: [SplitExpenseParticipant]] = [:]
    @Published var users: [UUID: User] = [:]
    @Published var savingsGoalsList: [SavingsGoal] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showingAddExpense = false
    
    // Previous month data
    @Published var previousMonthIncomeTotal: Double = 0
    @Published var previousMonthExpensesTotal: Double = 0
    @Published var previousMonthFixedExpensesTotal: Double = 0
    @Published var previousMonthVariableExpensesTotal: Double = 0
    @Published var previousMonthSavingsTotal: Double = 0
    
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
    private let fixedExpenseService = FixedExpenseService.shared
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
            monthlyExpensesTotal = monthlyExpensesList.reduce(0) { $0 + $1.amount }
            
            // Calculate fixed and variable expenses
            let variable = monthlyExpensesList.reduce(0) { $0 + $1.amount }
            
            monthlyVariableExpensesTotal = variable
            
            // Load previous month expenses
            print("Loading previous month expenses")
            let previousExpensesList = try await expenseService.getExpenses(forUserID: userID, in: previousStartDate...previousEndDate)
            previousMonthExpensesTotal = previousExpensesList.reduce(0) { $0 + $1.amount }
            
            // Calculate fixed and variable expenses for previous month
            let (prevVariable) = previousExpensesList.reduce(0) { $0 + $1.amount }
            
            previousMonthVariableExpensesTotal = prevVariable
            print("Previous Month Expenses Calculated:", previousMonthFixedExpensesTotal, previousMonthVariableExpensesTotal    )
            
            // Load current month income
            print("Loading current month income")
            let monthlyIncomeList = try await incomeService.getIncomes(forUserID: userID, in: startDate...endDate)
            monthlyIncomeTotal = monthlyIncomeList.reduce(0) { $0 + $1.amount }
            
            // Load previous month income
            print("Loading previous month income")
            let previousIncomeList = try await incomeService.getIncomes(forUserID: userID, in: previousStartDate...previousEndDate)
            previousMonthIncomeTotal = previousIncomeList.reduce(0) { $0 + $1.amount }
            
            previousMonthSavingsTotal = previousMonthIncomeTotal - previousMonthExpensesTotal
            
            // Get fixed expenses for the month
            fixedExpensesList = try await fixedExpenseService.getFixedExpenses(forUserID: userID)
            print("Retrieved fixed expenses:",fixedExpensesList.count)
            
            monthlyFixedExpensesTotal = fixedExpensesList.reduce(0) { $0 + $1.amount }
            
            // Calculate category expenses
            categoryExpenses = Dictionary(grouping: monthlyExpensesList, by: { $0.categoryID })
                .mapValues { expenses in expenses.reduce(0) { $0 + $1.amount } }
            
            // Get recent expenses for the month
            recentExpensesList = Array(monthlyExpensesList
                .sorted(by: { $0.transactionDate > $1.transactionDate }))
            
            // Load outstanding payments
            print("Loading outstanding payments")
            outstandingPaymentsList = try await outstandingService.getOutstandingPayments(forUserID: userID)
            
            // Load split expenses
            print("Loading split expenses")
            splitExpensesList = try await splitExpenseService.getUnpaidSplitExpenses(userID: userID)
            
            // Load split expense participants
            for expense in splitExpensesList {
                let participants = try await splitExpenseParticipantService.getUnpaidParticipants(forExpenseID: expense.id)
                splitParticipants[expense.id] = participants
            }
            
            // Load users for split expenses
            let userIDs = Set(splitExpensesList.map { $0.payerID } + splitParticipants.values.flatMap { $0.map { $0.userID } })
            for userID in userIDs {
                if let user = try await userService.getUser(id: userID) {
                    users[userID] = user
                }
            }
            
            // Load savings goals
            print("Loading savings goals")
            savingsGoalsList = try await savingsGoalService.getSavingsGoals(forUserID: userID)
            
            print("Data loading completed successfully")
            print("Monthly total: \(monthlyExpensesTotal)")
            print("Fixed expenses: \(monthlyFixedExpensesTotal)")
            print("Variable expenses: \(monthlyVariableExpensesTotal)")
            print("Recent expenses count: \(recentExpensesList.count)")
            print("Categories with expenses: \(categoryExpenses.count)")
            
        } catch {
            print("Error loading expenses data: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
    }
} 
