import Foundation
import FirebaseFirestore

class FirebaseService: DatabaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    // MARK: - Helper Methods
    private func documentReference(for collection: String, id: UUID) -> DocumentReference {
        return db.collection(collection).document(id.uuidString)
    }
    
    private func handleError(_ error: Error) -> Error {
        if let error = error as? DecodingError {
            return DatabaseError.invalidDocumentId
        }
        return error
    }
    
    // MARK: - User Operations
    func createUser(_ user: User) async throws -> User {
        let docRef = documentReference(for: "users", id: user.id)
        try docRef.setData(from: user)
        return user
    }
    
    func getUser(id: UUID) async throws -> User? {
        let docRef = documentReference(for: "users", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: User.self)
    }
    
    func getAllUsers() async throws -> [User] {
        let snapshot = try await db.collection("users").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: User.self) }
    }
    
    func updateUser(_ user: User) async throws -> User {
        let docRef = documentReference(for: "users", id: user.id)
        try docRef.setData(from: user, merge: true)
        return user
    }
    
    func deleteUser(id: UUID) async throws {
        let docRef = documentReference(for: "users", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Expense Operations
    func createExpense(_ expense: Expense) async throws -> Expense {
        let docRef = documentReference(for: "expenses", id: expense.id)
        try docRef.setData(from: expense)
        return expense
    }
    
    func getExpense(id: UUID) async throws -> Expense? {
        let docRef = documentReference(for: "expenses", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: Expense.self)
    }
    
    func getExpenses(forUserID: UUID) async throws -> [Expense] {
        let snapshot = try await db.collection("expenses")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Expense.self) }
    }
    
    func getAllExpenses() async throws -> [Expense] {
        let snapshot = try await db.collection("expenses").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Expense.self) }
    }
    
    func updateExpense(_ expense: Expense) async throws -> Expense {
        let docRef = documentReference(for: "expenses", id: expense.id)
        try docRef.setData(from: expense, merge: true)
        return expense
    }
    
    func deleteExpense(id: UUID) async throws {
        let docRef = documentReference(for: "expenses", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Fixed Expense Operations
    func createFixedExpense(_ fixedExpense: FixedExpense) async throws -> FixedExpense {
        let docRef = documentReference(for: "fixedExpenses", id: fixedExpense.id)
        try docRef.setData(from: fixedExpense)
        return fixedExpense
    }
    
    func getFixedExpense(id: UUID) async throws -> FixedExpense? {
        let docRef = documentReference(for: "fixedExpenses", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: FixedExpense.self)
    }
    
    func getFixedExpenses(forUserID: UUID) async throws -> [FixedExpense] {
        let snapshot = try await db.collection("fixedExpenses")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FixedExpense.self) }
    }
    
    func updateFixedExpense(_ fixedExpense: FixedExpense) async throws -> FixedExpense {
        let docRef = documentReference(for: "fixedExpenses", id: fixedExpense.id)
        try docRef.setData(from: fixedExpense, merge: true)
        return fixedExpense
    }
    
    func deleteFixedExpense(id: UUID) async throws {
        let docRef = documentReference(for: "fixedExpenses", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Income Operations
    func createIncome(_ income: Income) async throws -> Income {
        let docRef = documentReference(for: "incomes", id: income.id)
        try docRef.setData(from: income)
        return income
    }
    
    func getIncome(id: UUID) async throws -> Income? {
        let docRef = documentReference(for: "incomes", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: Income.self)
    }
    
    func getIncomes(forUserID: UUID) async throws -> [Income] {
        let snapshot = try await db.collection("incomes")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Income.self) }
    }
    
    func getAllIncomes() async throws -> [Income] {
        let snapshot = try await db.collection("incomes").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Income.self) }
    }
    
    func updateIncome(_ income: Income) async throws -> Income {
        let docRef = documentReference(for: "incomes", id: income.id)
        try docRef.setData(from: income, merge: true)
        return income
    }
    
    func deleteIncome(id: UUID) async throws {
        let docRef = documentReference(for: "incomes", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Category Operations
    func createCategory(_ category: Category) async throws -> Category {
        let docRef = documentReference(for: "categories", id: category.id)
        try docRef.setData(from: category)
        return category
    }
    
    func getCategory(id: UUID) async throws -> Category? {
        let docRef = documentReference(for: "categories", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: Category.self)
    }
    
    func getCategories() async throws -> [Category] {
        let snapshot = try await db.collection("categories").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Category.self) }
    }
    
    func updateCategory(_ category: Category) async throws -> Category {
        let docRef = documentReference(for: "categories", id: category.id)
        try docRef.setData(from: category, merge: true)
        return category
    }
    
    func deleteCategory(id: UUID) async throws {
        let docRef = documentReference(for: "categories", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Budget Operations
    func createBudget(_ budget: Budget) async throws -> Budget {
        let docRef = documentReference(for: "budgets", id: budget.id)
        try docRef.setData(from: budget)
        return budget
    }
    
    func getBudget(id: UUID) async throws -> Budget? {
        let docRef = documentReference(for: "budgets", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: Budget.self)
    }
    
    func getBudgets(forUserID: UUID) async throws -> [Budget] {
        let snapshot = try await db.collection("budgets")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Budget.self) }
    }
    
    func getAllBudgets() async throws -> [Budget] {
        let snapshot = try await db.collection("budgets").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Budget.self) }
    }
    
    func updateBudget(_ budget: Budget) async throws -> Budget {
        let docRef = documentReference(for: "budgets", id: budget.id)
        try docRef.setData(from: budget, merge: true)
        return budget
    }
    
    func deleteBudget(id: UUID) async throws {
        let docRef = documentReference(for: "budgets", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Savings Goal Operations
    func createSavingsGoal(_ savingsGoal: SavingsGoal) async throws -> SavingsGoal {
        let docRef = documentReference(for: "savingsGoals", id: savingsGoal.id)
        try docRef.setData(from: savingsGoal)
        return savingsGoal
    }
    
    func getSavingsGoal(id: UUID) async throws -> SavingsGoal? {
        let docRef = documentReference(for: "savingsGoals", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: SavingsGoal.self)
    }
    
    func getSavingsGoals(forUserID: UUID) async throws -> [SavingsGoal] {
        let snapshot = try await db.collection("savingsGoals")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SavingsGoal.self) }
    }
    
    func getAllSavingsGoals() async throws -> [SavingsGoal] {
        let snapshot = try await db.collection("savingsGoals").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SavingsGoal.self) }
    }
    
    func updateSavingsGoal(_ savingsGoal: SavingsGoal) async throws -> SavingsGoal {
        let docRef = documentReference(for: "savingsGoals", id: savingsGoal.id)
        try docRef.setData(from: savingsGoal, merge: true)
        return savingsGoal
    }
    
    func deleteSavingsGoal(id: UUID) async throws {
        let docRef = documentReference(for: "savingsGoals", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Friendship Operations
    func createFriendship(_ friendship: Friendship) async throws -> Friendship {
        let docRef = documentReference(for: "friendships", id: friendship.id)
        try docRef.setData(from: friendship)
        return friendship
    }
    
    func getFriendship(id: UUID) async throws -> Friendship? {
        let docRef = documentReference(for: "friendships", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: Friendship.self)
    }
    
    func getFriendships(forUserID: UUID) async throws -> [Friendship] {
        let snapshot = try await db.collection("friendships")
            .whereField("user1ID", isEqualTo: forUserID.uuidString)
            .whereField("user2ID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Friendship.self) }
    }
    
    func updateFriendship(_ friendship: Friendship) async throws -> Friendship {
        let docRef = documentReference(for: "friendships", id: friendship.id)
        try docRef.setData(from: friendship, merge: true)
        return friendship
    }
    
    func deleteFriendship(id: UUID) async throws {
        let docRef = documentReference(for: "friendships", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Shared Data Settings Operations
    func createSharedDataSettings(_ settings: SharedDataSettings) async throws -> SharedDataSettings {
        let docRef = documentReference(for: "sharedDataSettings", id: settings.id)
        try docRef.setData(from: settings)
        return settings
    }
    
    func getSharedDataSettings(id: UUID) async throws -> SharedDataSettings? {
        let docRef = documentReference(for: "sharedDataSettings", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: SharedDataSettings.self)
    }
    
    func getSharedDataSettings(forUserID: UUID) async throws -> [SharedDataSettings] {
        let snapshot = try await db.collection("sharedDataSettings")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SharedDataSettings.self) }
    }
    
    func updateSharedDataSettings(_ settings: SharedDataSettings) async throws -> SharedDataSettings {
        let docRef = documentReference(for: "sharedDataSettings", id: settings.id)
        try docRef.setData(from: settings, merge: true)
        return settings
    }
    
    func deleteSharedDataSettings(id: UUID) async throws {
        let docRef = documentReference(for: "sharedDataSettings", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Split Expense Operations
    func createSplitExpense(_ splitExpense: SplitExpense) async throws -> SplitExpense {
        let docRef = documentReference(for: "splitExpenses", id: splitExpense.id)
        try docRef.setData(from: splitExpense)
        return splitExpense
    }
    
    func getSplitExpense(id: UUID) async throws -> SplitExpense? {
        let docRef = documentReference(for: "splitExpenses", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: SplitExpense.self)
    }
    
    func getSplitExpenses(forUserID: UUID) async throws -> [SplitExpense] {
        // Get expenses where user is either creator or payer
        let creatorSnapshot = try await db.collection("splitExpenses")
            .whereField("creatorID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        
        let payerSnapshot = try await db.collection("splitExpenses")
            .whereField("payerID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        
        var splitExpenses = try creatorSnapshot.documents.compactMap { try $0.data(as: SplitExpense.self) }
        let payerExpenses = try payerSnapshot.documents.compactMap { try $0.data(as: SplitExpense.self) }
        
        // Add payer expenses that aren't already included (where user is payer but not creator)
        for expense in payerExpenses {
            if !splitExpenses.contains(where: { $0.id == expense.id }) {
                splitExpenses.append(expense)
            }
        }
        
        return splitExpenses
    }
    
    func updateSplitExpense(_ splitExpense: SplitExpense) async throws -> SplitExpense {
        let docRef = documentReference(for: "splitExpenses", id: splitExpense.id)
        try docRef.setData(from: splitExpense, merge: true)
        return splitExpense
    }
    
    func deleteSplitExpense(id: UUID) async throws {
        let docRef = documentReference(for: "splitExpenses", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Split Expense Participant Operations
    func createSplitExpenseParticipant(_ participant: SplitExpenseParticipant) async throws -> SplitExpenseParticipant {
        let docRef = documentReference(for: "splitExpenseParticipants", id: participant.id)
        try docRef.setData(from: participant)
        return participant
    }
    
    func getSplitExpenseParticipant(id: UUID) async throws -> SplitExpenseParticipant? {
        let docRef = documentReference(for: "splitExpenseParticipants", id: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: SplitExpenseParticipant.self)
    }
    
    func getSplitExpenseParticipants(forSplitID: UUID) async throws -> [SplitExpenseParticipant] {
        let snapshot = try await db.collection("splitExpenseParticipants")
            .whereField("splitID", isEqualTo: forSplitID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SplitExpenseParticipant.self) }
    }
    
    func updateSplitExpenseParticipant(_ participant: SplitExpenseParticipant) async throws -> SplitExpenseParticipant {
        let docRef = documentReference(for: "splitExpenseParticipants", id: participant.id)
        try docRef.setData(from: participant, merge: true)
        return participant
    }
    
    func deleteSplitExpenseParticipant(id: UUID) async throws {
        let docRef = documentReference(for: "splitExpenseParticipants", id: id)
        try await docRef.delete()
    }
    
    // MARK: - Vendor Operations
    func createVendor(_ vendor: Vendor) async throws -> Vendor {
        return try await VendorService.shared.createVendor(vendor)
    }
    
    func getVendor(id: UUID) async throws -> Vendor? {
        return try await VendorService.shared.getVendor(id: id)
    }
    
    func getVendors(forUserID: UUID) async throws -> [Vendor] {
        return try await VendorService.shared.getVendors(forUserID: forUserID)
    }
    
    func getAllVendors() async throws -> [Vendor] {
        return try await VendorService.shared.getAllVendors()
    }
    
    func updateVendor(_ vendor: Vendor) async throws -> Vendor{
        return try await VendorService.shared.updateVendor(vendor)
    }
    
    func deleteVendor(id: UUID) async throws {
        try await VendorService.shared.deleteVendor(id: id)
    }
    
    func getVendors(forCategoryID: UUID) async throws -> [Vendor] {
        return try await VendorService.shared.getVendors(forCategoryID: forCategoryID)
    }
    
    func searchVendors(query: String) async throws -> [Vendor] {
        return try await VendorService.shared.searchVendors(query: query)
    }
    
    func getFrequentVendors(forUserID: UUID, limit: Int = 5) async throws -> [Vendor] {
        return try await VendorService.shared.getFrequentVendors(forUserID: forUserID, limit: limit)
    }
    
    // MARK: - Outstanding Payment Operations
    func createOutstandingPayment(_ payment: OutstandingPayment) async throws -> OutstandingPayment {
        return try await OutstandingService.shared.createOutstandingPayment(payment)
    }
    
    func getOutstandingPayment(id: UUID) async throws -> OutstandingPayment? {
        return try await OutstandingService.shared.getOutstandingPayment(id: id)
    }
    
    func getOutstandingPayments(forUserID: UUID) async throws -> [OutstandingPayment] {
        return try await OutstandingService.shared.getOutstandingPayments(forUserID: forUserID)
    }
    
    func updateOutstandingPayment(_ payment: OutstandingPayment) async throws -> OutstandingPayment {
        return try await OutstandingService.shared.updateOutstandingPayment(payment)
    }
    
    func deleteOutstandingPayment(id: UUID) async throws {
        try await OutstandingService.shared.deleteOutstandingPayment(id: id)
    }
    
    func getOutstandingPayments(forCategoryID: UUID) async throws -> [OutstandingPayment] {
        return try await OutstandingService.shared.getOutstandingPayments(forCategoryID: forCategoryID)
    }
    
    func getTotalOutstandingAmount(forUserID: UUID) async throws -> Double {
        return try await OutstandingService.shared.getTotalOutstandingAmount(forUserID: forUserID)
    }
    
    func getOverduePayments(forUserID: UUID) async throws -> [OutstandingPayment] {
        return try await OutstandingService.shared.getOverduePayments(forUserID: forUserID)
    }
    
    func markOutstandingPaymentAsPaid(_ payment: OutstandingPayment) async throws -> OutstandingPayment {
        return try await OutstandingService.shared.markAsPaid(payment)
    }
} 
