import Foundation
import CoreData

class CoreDataService: DatabaseService {
    static let shared = CoreDataService()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "VaultModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - User Operations
    func createUser(_ user: User) async throws -> User {
        return try await UserService.shared.create(user)
    }
    
    func getUser(id: UUID) async throws -> User? {
        return try await UserService.shared.get(id: id)
    }
    
    func getAllUsers() async throws -> [User] {
        return try await UserService.shared.getAllUsers()
    }
    
    func updateUser(_ user: User) async throws -> User {
        return try await UserService.shared.update(user, id: user.id)
    }
    
    func deleteUser(id: UUID) async throws {
        try await UserService.shared.delete(id: id)
    }
    
    // MARK: - Expense Operations
    func createExpense(_ expense: Expense) async throws -> Expense {
        return try await ExpenseService.shared.create(expense)
    }
    
    func getExpense(id: UUID) async throws -> Expense? {
        return try await ExpenseService.shared.get(id: id)
    }
    
    func getExpenses(forUserID: UUID) async throws -> [Expense] {
        return try await ExpenseService.shared.getForUser(forUserID)
    }
    
    func getAllExpenses() async throws -> [Expense] {
        return try await ExpenseService.shared.getAll()
    }
    
    func updateExpense(_ expense: Expense) async throws -> Expense {
        return try await ExpenseService.shared.update(expense, id: expense.id)
    }
    
    func deleteExpense(id: UUID) async throws {
        try await ExpenseService.shared.delete(id: id)
    }
    
    // MARK: - Fixed Expense Operations
    func createFixedExpense(_ fixedExpense: FixedExpense) async throws -> FixedExpense {
        return try await ExpenseService.shared.createFixedExpense(fixedExpense)
    }
    
    func getFixedExpense(id: UUID) async throws -> FixedExpense? {
        return try await ExpenseService.shared.getFixedExpense(id: id)
    }
    
    func getFixedExpenses(forUserID: UUID) async throws -> [FixedExpense] {
        return try await ExpenseService.shared.getFixedExpenses(forUserID: forUserID)
    }
    
    func updateFixedExpense(_ fixedExpense: FixedExpense) async throws -> FixedExpense {
        return try await ExpenseService.shared.updateFixedExpense(fixedExpense)
    }
    
    func deleteFixedExpense(id: UUID) async throws {
        try await ExpenseService.shared.deleteFixedExpense(id: id)
    }
    
    // MARK: - Income Operations
    func createIncome(_ income: Income) async throws -> Income {
        return try await IncomeService.shared.create(income)
    }
    
    func getIncome(id: UUID) async throws -> Income? {
        return try await IncomeService.shared.get(id: id)
    }
    
    func getIncomes(forUserID: UUID) async throws -> [Income] {
        return try await IncomeService.shared.getForUser(forUserID)
    }
    
    func getAllIncomes() async throws -> [Income] {
        return try await IncomeService.shared.getAll()
    }
    
    func updateIncome(_ income: Income) async throws -> Income {
        return try await IncomeService.shared.update(income, id: income.id)
    }
    
    func deleteIncome(id: UUID) async throws {
        try await IncomeService.shared.delete(id: id)
    }
    
    // MARK: - Category Operations
    func createCategory(_ category: Category) async throws -> Category {
        return try await CategoryService.shared.create(category)
    }
    
    func getCategory(id: UUID) async throws -> Category? {
        return try await CategoryService.shared.get(id: id)
    }
    
    func getCategories() async throws -> [Category] {
        return try await CategoryService.shared.getAll()
    }
    
    func updateCategory(_ category: Category) async throws -> Category {
        return try await CategoryService.shared.update(category, id: category.id)
    }
    
    func deleteCategory(id: UUID) async throws {
        try await CategoryService.shared.delete(id: id)
    }
    
    // MARK: - Budget Operations
    func createBudget(_ budget: Budget) async throws -> Budget {
        return try await BudgetService.shared.create(budget)
    }
    
    func getBudget(id: UUID) async throws -> Budget? {
        return try await BudgetService.shared.get(id: id)
    }
    
    func getBudgets(forUserID: UUID) async throws -> [Budget] {
        return try await BudgetService.shared.getForUser(forUserID)
    }
    
    func getAllBudgets() async throws -> [Budget] {
        return try await BudgetService.shared.getAll()
    }
    
    func updateBudget(_ budget: Budget) async throws -> Budget {
        return try await BudgetService.shared.update(budget, id: budget.id)
    }
    
    func deleteBudget(id: UUID) async throws {
        try await BudgetService.shared.delete(id: id)
    }
    
    // MARK: - Savings Goal Operations
    func createSavingsGoal(_ savingsGoal: SavingsGoal) async throws -> SavingsGoal {
        return try await SavingsGoalService.shared.create(savingsGoal)
    }
    
    func getSavingsGoal(id: UUID) async throws -> SavingsGoal? {
        return try await SavingsGoalService.shared.get(id: id)
    }
    
    func getSavingsGoals(forUserID: UUID) async throws -> [SavingsGoal] {
        return try await SavingsGoalService.shared.getForUser(forUserID)
    }
    
    func getAllSavingsGoals() async throws -> [SavingsGoal] {
        return try await SavingsGoalService.shared.getAll()
    }
    
    func updateSavingsGoal(_ savingsGoal: SavingsGoal) async throws -> SavingsGoal {
        return try await SavingsGoalService.shared.update(savingsGoal, id: savingsGoal.id)
    }
    
    func deleteSavingsGoal(id: UUID) async throws {
        try await SavingsGoalService.shared.delete(id: id)
    }
    
    // MARK: - Friendship Operations
    func createFriendship(_ friendship: Friendship) async throws -> Friendship {
        return try await FriendsService.shared.create(friendship)
    }
    
    func getFriendship(id: UUID) async throws -> Friendship? {
        return try await FriendsService.shared.get(id: id)
    }
    
    func getFriendships(forUserID: UUID) async throws -> [Friendship] {
        return try await FriendsService.shared.getForUser(forUserID)
    }
    
    func updateFriendship(_ friendship: Friendship) async throws -> Friendship {
        return try await FriendsService.shared.update(friendship, id: friendship.id)
    }
    
    func deleteFriendship(id: UUID) async throws {
        try await FriendsService.shared.delete(id: id)
    }
    
    // MARK: - Shared Data Settings Operations
    func createSharedDataSettings(_ settings: SharedDataSettings) async throws -> SharedDataSettings {
        return try await SharedDataSettingsService.shared.create(settings)
    }
    
    func getSharedDataSettings(id: UUID) async throws -> SharedDataSettings? {
        return try await SharedDataSettingsService.shared.get(id: id)
    }
    
    func getSharedDataSettings(forUserID: UUID) async throws -> [SharedDataSettings] {
        return try await SharedDataSettingsService.shared.getForUser(forUserID)
    }
    
    func updateSharedDataSettings(_ settings: SharedDataSettings) async throws -> SharedDataSettings {
        return try await SharedDataSettingsService.shared.update(settings, id: settings.id)
    }
    
    func deleteSharedDataSettings(id: UUID) async throws {
        try await SharedDataSettingsService.shared.delete(id: id)
    }
    
    // MARK: - Split Expense Operations
    func createSplitExpense(_ splitExpense: SplitExpense) async throws -> SplitExpense {
        return try await SplitExpenseService.shared.create(splitExpense)
    }
    
    func getSplitExpense(id: UUID) async throws -> SplitExpense? {
        return try await SplitExpenseService.shared.get(id: id)
    }
    
    func getSplitExpenses(forUserID: UUID) async throws -> [SplitExpense] {
        return try await SplitExpenseService.shared.getForUser(forUserID)
    }
    
    func updateSplitExpense(_ splitExpense: SplitExpense) async throws -> SplitExpense {
        return try await SplitExpenseService.shared.update(splitExpense, id: splitExpense.id)
    }
    
    func deleteSplitExpense(id: UUID) async throws {
        try await SplitExpenseService.shared.delete(id: id)
    }
    
    // MARK: - Split Expense Participant Operations
    func createSplitExpenseParticipant(_ participant: SplitExpenseParticipant) async throws -> SplitExpenseParticipant {
        return try await SplitExpenseParticipantService.shared.create(participant)
    }
    
    func getSplitExpenseParticipant(id: UUID) async throws -> SplitExpenseParticipant? {
        return try await SplitExpenseParticipantService.shared.get(id: id)
    }
    
    func getSplitExpenseParticipants(forSplitID: UUID) async throws -> [SplitExpenseParticipant] {
        return try await SplitExpenseParticipantService.shared.getSplitExpenseParticipants(forSplitID: forSplitID)
    }
    
    func updateSplitExpenseParticipant(_ participant: SplitExpenseParticipant) async throws -> SplitExpenseParticipant {
        return try await SplitExpenseParticipantService.shared.update(participant, id: participant.id)
    }
    
    func deleteSplitExpenseParticipant(id: UUID) async throws {
        try await SplitExpenseParticipantService.shared.delete(id: id)
    }
} 
