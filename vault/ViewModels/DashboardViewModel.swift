import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    // Current month data
    @Published var monthlyIncome: Double = 0
    @Published var monthlyExpenses: Double = 0
    @Published var monthlyFixedExpenses: Double = 0
    @Published var monthlyVariableExpenses: Double = 0
    @Published var monthlySavings: Double = 0
    
    // Previous month data
    @Published var previousMonthIncome: Double = 0
    @Published var previousMonthExpenses: Double = 0
    @Published var previousMonthFixedExpenses: Double = 0
    @Published var previousMonthVariableExpenses: Double = 0
    @Published var previousMonthSavings: Double = 0
    
    // Split expenses data
    @Published var splitExpensesYouOwe: [SplitExpense] = []
    @Published var splitExpensesOwedToYou: [SplitExpense] = []
    @Published var splitParticipants: [UUID: [SplitExpenseParticipant]] = [:]
    @Published var users: [UUID: User] = [:]
    
    @Published var recentExpenses: [Expense] = []
    @Published var categories: [UUID: Category] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedDate: Date = Date() {
        didSet {
            print("Selected date changed to: \(Date.monthYearString(from: selectedDate))")
        }
    }
    
    private let expenseService = ExpenseService.shared
    private let incomeService = IncomeService.shared
    private let categoryService = CategoryService.shared
    private let splitExpenseService = SplitExpenseService.shared
    private let splitExpenseParticipantService = SplitExpenseParticipantService.shared
    private let userService = UserService.shared
    
    func loadDashboardData(forUserID userID: UUID) async {
        isLoading = true
        error = nil
        
        do {
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
            
            print("Loading data for current month: \(startDate) to \(endDate)")
            print("Loading data for previous month: \(previousStartDate) to \(previousEndDate)")
            
            // Load categories first as they're referenced by expenses
            // print("Loading categories")
            let allCategories = try await categoryService.getAllCategories()
            categories = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
            
            // Load split expenses
            // print("Loading split expenses")
            
            // Get expenses where you owe others (you are participant, not payer)
            let expensesYouOwe = try await splitExpenseService.getSplitExpensesUserOwes(forUserID: userID)
            splitExpensesYouOwe = expensesYouOwe.filter { $0.payerID == userID }
            
            // Get expenses where others owe you (you are the payer)
            let expensesOtherOweYou = try await splitExpenseService.getSplitExpensesOthersOweUser(userID: userID)
            splitExpensesOwedToYou = expensesOtherOweYou.filter { $0.payerID != userID }
            
            // print("You owe: \(splitExpensesYouOwe.count) split expenses")
            // print(splitExpensesYouOwe)
            // print("Split expenses you owe details:")
            //for expense in splitExpensesYouOwe {
            //    print("- Description: \(expense.expenseDescription), Amount: \(expense.totalAmount), Person Owed: \(expense.creatorID)")
            //}
            
            // print("Owed to you: \(splitExpensesOwedToYou.count) split expenses")
            // print(splitExpensesOwedToYou)
            // print("Split expenses owed to you details:")
            // for expense in splitExpensesOwedToYou {
            //    print("- Description: \(expense.expenseDescription), Amount: \(expense.totalAmount), Payer: \(expense.payerID)")
            // }
            
            // Load split expense participants and user details
            //print("Loading split expense participants")
            let allSplitExpenses = splitExpensesYouOwe + splitExpensesOwedToYou
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
            
            // Load current month expenses
            print("Loading current month expenses")
            let monthlyExpensesList = try await expenseService.getExpenses(forUserID: userID, in: startDate...endDate)
            monthlyExpenses = monthlyExpensesList.reduce(0) { $0 + $1.amount }
            
            // Calculate fixed and variable expenses for current month
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
            
            // Load current month income
            print("Loading current month income")
            let monthlyIncomeList = try await incomeService.getIncomes(forUserID: userID, in: startDate...endDate)
            monthlyIncome = monthlyIncomeList.reduce(0) { $0 + $1.amount }
            
            // Load previous month income
            print("Loading previous month income")
            let previousIncomeList = try await incomeService.getIncomes(forUserID: userID, in: previousStartDate...previousEndDate)
            previousMonthIncome = previousIncomeList.reduce(0) { $0 + $1.amount }
            
            // Calculate savings for both months
            monthlySavings = monthlyIncome - monthlyExpenses
            previousMonthSavings = previousMonthIncome - previousMonthExpenses
            
            print("Current month - Income: \(monthlyIncome), Expenses: \(monthlyExpenses), Savings: \(monthlySavings)")
            print("Previous month - Income: \(previousMonthIncome), Expenses: \(previousMonthExpenses), Savings: \(previousMonthSavings)")
            
            // Get recent expenses (last 5)
            recentExpenses = Array(monthlyExpensesList
                .sorted(by: { $0.transactionDate > $1.transactionDate })
                .prefix(5))
            
        } catch {
            print("Error loading dashboard data: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
        print("Finished loading dashboard data for \(Date.monthYearString(from: selectedDate))")
    }
} 
