import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    // Current month data
    @Published var monthlyIncomeTotal: Double = 0
    @Published var monthlyExpensesTotal: Double = 0
    @Published var monthlySavingsTotal: Double = 0
    
    // Previous month data
    @Published var previousMonthIncomeTotal: Double = 0
    @Published var previousMonthExpensesTotal: Double = 0
    @Published var previousMonthSavingsTotal: Double = 0
    
    // Split expenses data
    @Published var splitExpensesYouOweList: [SplitExpense] = []
    @Published var splitExpensesOwedToYouList: [SplitExpense] = []
    @Published var splitExpensesList: [(expense: SplitExpense, participants: [SplitExpenseParticipant])] = []
    @Published var splitParticipants: [UUID: [SplitExpenseParticipant]] = [:]
    @Published var users: [UUID: User] = [:]
    
    @Published var recentExpensesList: [Expense] = []
    @Published var categories: [UUID: Category] = [:]
    @Published var isLoading = false
    @Published var isLoadingPayments = false
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
            print()
            print("------ Dashboard View ------ ")
            
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
            
            var allExpenses: [SplitExpense] = []
            
            // Load split expenses where current user is the payer
            let expensesYouOwe = try await splitExpenseService.getSplitExpensesUserOwes(forUserID: userID)
            
            // Get expenses where others owe you (you are the creator)
            let expensesOtherOweYou = try await splitExpenseService.getSplitExpensesOthersOweUser(userID: userID)
            
            allExpenses = expensesYouOwe + expensesOtherOweYou
            
            // Load split expense participants and user details
            let allSplitExpenses = allExpenses
            
            // Load participants for each split expense
            var expensesWithParticipants: [(expense: SplitExpense, participants: [SplitExpenseParticipant])] = []
            
            // Load participants for each split expense
            for expense in allSplitExpenses {
                let participants = try await splitExpenseParticipantService.getParticipants(forExpenseID: expense.id)
                var relevantParticipant: [SplitExpenseParticipant] = []
                
                // If you are the creator of the split expense
                if expense.creatorID == userID {
                    
                    for participant in participants {
                        relevantParticipant.append(participant)
                    }
                    
                } else {
                    // If someone else is creator, get current user's participant status
                    for participant in participants {
                        
                        if participant.userID == userID {
                            relevantParticipant.append(participant)
                            break
                        }
                        
                    }
                }
                
                // Only add the expense if we found the relevant participant
                expensesWithParticipants.append((
                    expense: expense,
                    participants: relevantParticipant
                ))
                
            }
            
            // Sort by creation date, most recent first
            expensesWithParticipants.sort { $0.expense.creationDate > $1.expense.creationDate }
            
            splitExpensesList = expensesWithParticipants
            
            splitExpensesYouOweList = allExpenses.filter { $0.creatorID != userID }
            
            splitExpensesOwedToYouList = allExpenses.filter { $0.creatorID == userID }
            
            // Load current month expenses
            //print("Loading current month expenses")
            let monthlyExpensesList = try await expenseService.getExpensesInDateRange(forUserID: userID, in: startDate...endDate)
            monthlyExpensesTotal = monthlyExpensesList.reduce(0) { $0 + $1.amount }
            
            // Load previous month expenses
            //print("Loading previous month expenses")
            let previousExpensesList = try await expenseService.getExpensesInDateRange(forUserID: userID, in: previousStartDate...previousEndDate)
            previousMonthExpensesTotal = previousExpensesList.reduce(0) { $0 + $1.amount }
            
            // Calculate fixed and variable expenses for previous month
            let (prevFixed, prevVariable) = previousExpensesList.reduce(into: (0.0, 0.0)) { result, expense in
                if let category = categories[expense.categoryID], category.fixedExpense {
                    result.0 += expense.amount
                } else {
                    result.1 += expense.amount
                }
            }
                
            // Load current month income
            //print("Loading current month income")
            let monthlyIncomeList = try await incomeService.getIncomes(forUserID: userID, in: startDate...endDate)
            monthlyIncomeTotal = monthlyIncomeList.reduce(0) { $0 + $1.amount }
            
            // Load previous month income
            //print("Loading previous month income")
            let previousIncomeList = try await incomeService.getIncomes(forUserID: userID, in: previousStartDate...previousEndDate)
            previousMonthIncomeTotal = previousIncomeList.reduce(0) { $0 + $1.amount }
            
            // Calculate savings for both months
            monthlySavingsTotal = monthlyIncomeTotal - monthlyExpensesTotal
            previousMonthSavingsTotal = previousMonthIncomeTotal - previousMonthExpensesTotal
            
            print("Current month - Income: \(monthlyIncomeTotal), Expenses: \(monthlyExpensesTotal), Savings: \(monthlySavingsTotal)")
            print("Previous month - Income: \(previousMonthIncomeTotal), Expenses: \(previousMonthExpensesTotal), Savings: \(previousMonthSavingsTotal)")
            
            // Get recent expenses (last 5)
            recentExpensesList = Array(monthlyExpensesList
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
