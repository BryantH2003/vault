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
    @Published var previousMonthCategoryExpenses: [UUID: Double] = [:]
    @Published var outstandingPaymentsList: [OutstandingPayment] = []
    @Published var splitExpensesYouOweList: [SplitExpense] = []
    @Published var splitExpensesOwedToYouList: [SplitExpense] = []
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
            print()
            print("------ Expense View ------ ")
            
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
            
            // Load categories first as they're referenced by expenses
            // print("Loading categories")
            let allCategories = try await categoryService.getAllCategories()
            categories = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
            
            // Load monthly expenses list
            // print("Loading monthly expenses")
            let monthlyExpensesList = try await expenseService.getExpensesInDateRange(forUserID: userID, in: startDate...endDate)
            monthlyExpensesTotal = monthlyExpensesList.reduce(0) { $0 + $1.amount }
            
            // Calculate variable expenses total for this month
            let variable = monthlyExpensesList.reduce(0) { $0 + $1.amount }
            
            monthlyVariableExpensesTotal = variable
            
            // Load previous month expenses list
            // print("Loading previous month expenses")
            let previousExpensesList = try await expenseService.getExpensesInDateRange(forUserID: userID, in: previousStartDate...previousEndDate)
            previousMonthExpensesTotal = previousExpensesList.reduce(0) { $0 + $1.amount }
            
            // Calculate variable expenses total for previous month
            let prevVariable = previousExpensesList.reduce(0) { $0 + $1.amount }
            
            previousMonthVariableExpensesTotal = prevVariable
            
            // Load current month income list
            // print("Loading current month income")
            let monthlyIncomeList = try await incomeService.getIncomes(forUserID: userID, in: startDate...endDate)
            
            // Calculate total income for this month
            monthlyIncomeTotal = monthlyIncomeList.reduce(0) { $0 + $1.amount }
            
            // Load previous month income list
            // print("Loading previous month income")
            let previousIncomeList = try await incomeService.getIncomes(forUserID: userID, in: previousStartDate...previousEndDate)
            
            // Calculate total income for previous month
            previousMonthIncomeTotal = previousIncomeList.reduce(0) { $0 + $1.amount }
            
            // Calculate total savings for previous month
            previousMonthSavingsTotal = previousMonthIncomeTotal - previousMonthExpensesTotal
            
            // Get fixed expenses for the month list
            fixedExpensesList = try await fixedExpenseService.getFixedExpenses(forUserID: userID)
            
            // Calculate total fixed expense for this month
            monthlyFixedExpensesTotal = fixedExpensesList.reduce(0) { $0 + $1.amount }
            
            // Calculate category expenses for current month
            categoryExpenses = Dictionary(grouping: monthlyExpensesList, by: { $0.categoryID })
                .mapValues { expenses in expenses.reduce(0) { $0 + $1.amount } }
            
            // Calculate category expenses for previous month
            previousMonthCategoryExpenses = Dictionary(grouping: previousExpensesList, by: { $0.categoryID })
                .mapValues { expenses in expenses.reduce(0) { $0 + $1.amount } }
            
            print(previousMonthCategoryExpenses)
            
            // Get recent expenses for the month list
            recentExpensesList = Array(monthlyExpensesList
                .sorted(by: { $0.transactionDate > $1.transactionDate }))
            
            // Load outstanding payments list
            // print("Loading outstanding payments")
            outstandingPaymentsList = try await outstandingService.getOutstandingPayments(forUserID: userID)
            
            // Load split expenses list
            let expensesYouOwe = try await splitExpenseService.getSplitExpensesUserOwes(forUserID: userID)
            splitExpensesYouOweList = expensesYouOwe.filter { $0.payerID == userID }
            
            // Get expenses where others owe you (you are the creator)
            let expensesOtherOweYou = try await splitExpenseService.getSplitExpensesOthersOweUser(userID: userID)
            splitExpensesOwedToYouList = expensesOtherOweYou.filter { $0.payerID != userID }
            
            // Load split expense participants and user details
            //print("Loading split expense participants")
            let allSplitExpenses = splitExpensesYouOweList + splitExpensesOwedToYouList
            for expense in allSplitExpenses {
                let participants = try await splitExpenseParticipantService.getUnpaidParticipants(forExpenseID: expense.id)
                splitParticipants[expense.id] = participants
                
                // Load user details for participants and payers
                let userIDs = Set([expense.payerID] + participants.map { $0.userID })
                for participantID in userIDs {
                    if users[participantID] == nil {
                        if let user = try await userService.getUser(id: participantID) {
                            users[participantID] = user
                            //print("Loaded user: \(user.fullName) for split expense")
                        }
                    }
                }
            }
            
            // Load savings goals list
            // print("Loading savings goals")
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
