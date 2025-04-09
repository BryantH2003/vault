import Foundation
import FirebaseFirestore

/// Protocol defining the database operations for the application
protocol DatabaseService {
    // MARK: - User Operations
    func createUser(_ user: User) async throws -> User
    func getUser(id: UUID) async throws -> User?
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: UUID) async throws
    
    // MARK: - Expense Operations
    func createExpense(_ expense: Expense) async throws -> Expense
    func getExpense(id: UUID) async throws -> Expense?
    func getExpenses(forUserID: UUID) async throws -> [Expense]
    func updateExpense(_ expense: Expense) async throws -> Expense
    func deleteExpense(id: UUID) async throws
    func getAllExpenses() async throws -> [Expense]
    
    // MARK: - Fixed Expense Operations
    func createFixedExpense(_ fixedExpense: FixedExpense) async throws -> FixedExpense
    func getFixedExpense(id: UUID) async throws -> FixedExpense?
    func getFixedExpenses(forUserID: UUID) async throws -> [FixedExpense]
    func updateFixedExpense(_ fixedExpense: FixedExpense) async throws -> FixedExpense
    func deleteFixedExpense(id: UUID) async throws
    
    // MARK: - Income Operations
    func createIncome(_ income: Income) async throws -> Income
    func getIncome(id: UUID) async throws -> Income?
    func getIncomes(forUserID: UUID) async throws -> [Income]
    func updateIncome(_ income: Income) async throws -> Income
    func deleteIncome(id: UUID) async throws
    func getAllIncomes() async throws -> [Income]
    
    // MARK: - Category Operations
    func createCategory(_ category: Category) async throws -> Category
    func getCategory(id: UUID) async throws -> Category?
    func getCategories() async throws -> [Category]
    func updateCategory(_ category: Category) async throws -> Category
    func deleteCategory(id: UUID) async throws
    
    // MARK: - Budget Operations
    func createBudget(_ budget: Budget) async throws -> Budget
    func getBudget(id: UUID) async throws -> Budget?
    func getBudgets(forUserID: UUID) async throws -> [Budget]
    func updateBudget(_ budget: Budget) async throws -> Budget
    func deleteBudget(id: UUID) async throws
    func getAllBudgets() async throws -> [Budget]
    
    // MARK: - Savings Goal Operations
    func createSavingsGoal(_ savingsGoal: SavingsGoal) async throws -> SavingsGoal
    func getSavingsGoal(id: UUID) async throws -> SavingsGoal?
    func getSavingsGoals(forUserID: UUID) async throws -> [SavingsGoal]
    func updateSavingsGoal(_ savingsGoal: SavingsGoal) async throws -> SavingsGoal
    func deleteSavingsGoal(id: UUID) async throws
    func getAllSavingsGoals() async throws -> [SavingsGoal]
    
    // MARK: - Friendship Operations
    func createFriendship(_ friendship: Friendship) async throws -> Friendship
    func getFriendship(id: UUID) async throws -> Friendship?
    func getFriendships(forUserID: UUID) async throws -> [Friendship]
    func updateFriendship(_ friendship: Friendship) async throws -> Friendship
    func deleteFriendship(id: UUID) async throws
    
    // MARK: - Shared Data Settings Operations
    func createSharedDataSettings(_ settings: SharedDataSettings) async throws -> SharedDataSettings
    func getSharedDataSettings(id: UUID) async throws -> SharedDataSettings?
    func getSharedDataSettings(forUserID: UUID) async throws -> [SharedDataSettings]
    func updateSharedDataSettings(_ settings: SharedDataSettings) async throws -> SharedDataSettings
    func deleteSharedDataSettings(id: UUID) async throws
    
    // MARK: - Split Expense Operations
    func createSplitExpense(_ splitExpense: SplitExpense) async throws -> SplitExpense
    func getSplitExpense(id: UUID) async throws -> SplitExpense?
    func getSplitExpenses(forUserID: UUID) async throws -> [SplitExpense]
    func updateSplitExpense(_ splitExpense: SplitExpense) async throws -> SplitExpense
    func deleteSplitExpense(id: UUID) async throws
    
    // MARK: - Split Expense Participant Operations
    func createSplitExpenseParticipant(_ participant: SplitExpenseParticipant) async throws -> SplitExpenseParticipant
    func getSplitExpenseParticipant(id: UUID) async throws -> SplitExpenseParticipant?
    func getSplitExpenseParticipants(forSplitID: UUID) async throws -> [SplitExpenseParticipant]
    func updateSplitExpenseParticipant(_ participant: SplitExpenseParticipant) async throws -> SplitExpenseParticipant
    func deleteSplitExpenseParticipant(id: UUID) async throws
    
    // MARK: - Vendor Operations
    func createVendor(_ vendor: Vendor) async throws -> Vendor
    func getVendor(id: UUID) async throws -> Vendor?
    func getVendors(forUserID: UUID) async throws -> [Vendor]
    func getAllVendors() async throws -> [Vendor]
    func updateVendor(_ vendor: Vendor) async throws -> Vendor
    func deleteVendor(id: UUID) async throws
    func getVendors(forCategoryID: UUID) async throws -> [Vendor]
    func searchVendors(query: String) async throws -> [Vendor]
    func getFrequentVendors(forUserID: UUID, limit: Int) async throws -> [Vendor]
    
    // MARK: - Outstanding Payment Operations
    func createOutstandingPayment(_ payment: OutstandingPayment) async throws -> OutstandingPayment
    func getOutstandingPayment(id: UUID) async throws -> OutstandingPayment?
    func getOutstandingPayments(forUserID: UUID) async throws -> [OutstandingPayment]
    func updateOutstandingPayment(_ payment: OutstandingPayment) async throws -> OutstandingPayment
    func deleteOutstandingPayment(id: UUID) async throws
    func getOutstandingPayments(forCategoryID: UUID) async throws -> [OutstandingPayment]
    func getTotalOutstandingAmount(forUserID: UUID) async throws -> Double
    func getOverduePayments(forUserID: UUID) async throws -> [OutstandingPayment]
    func markOutstandingPaymentAsPaid(_ payment: OutstandingPayment) async throws -> OutstandingPayment
}
    

enum DatabaseError: Error {
    case invalidId
    case invalidDocumentId
} 
