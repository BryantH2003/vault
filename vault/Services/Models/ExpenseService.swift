import Foundation
import FirebaseFirestore

/// Service for managing Expense entities
class ExpenseService {
    static let shared = ExpenseService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("expenses").document(id.uuidString)
    }
    
    func createExpense(_ expense: Expense) async throws -> Expense {
        let docRef = documentReference(for: expense.id)
        try docRef.setData(from: expense)
        return expense
    }
    
    func getExpense(id: UUID) async throws -> Expense? {
        let docRef = documentReference(for: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: Expense.self)
    }
    
    func getExpenses(forUserID: UUID) async throws -> [Expense] {
        print("Fetching expenses for user: \(forUserID)")
        let snapshot = try await db.collection("expenses")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        let expenses = try snapshot.documents.compactMap { try $0.data(as: Expense.self) }
        print("Found \(expenses.count) expenses")
        return expenses
    }
    
    func getAllExpenses() async throws -> [Expense] {
        let snapshot = try await db.collection("expenses").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Expense.self) }
    }
    
    func updateExpense(_ expense: Expense) async throws -> Expense {
        let docRef = documentReference(for: expense.id)
        try docRef.setData(from: expense, merge: true)
        return expense
    }
    
    func deleteExpense(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    /// Get expenses for a user in a date range
    func getExpenses(forUserID: UUID, in dateRange: ClosedRange<Date>) async throws -> [Expense] {
        print("Fetching expenses for user: \(forUserID) in date range: \(dateRange)")
        let snapshot = try await db.collection("expenses")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .whereField("transactionDate", isGreaterThanOrEqualTo: dateRange.lowerBound)
            .whereField("transactionDate", isLessThanOrEqualTo: dateRange.upperBound)
            .getDocuments()
        let expenses = try snapshot.documents.compactMap { try $0.data(as: Expense.self) }
        print("Found \(expenses.count) expenses in date range")
        return expenses
    }
    
    /// Get expenses for a user and category
    func getExpenses(forUserID: UUID, categoryID: UUID) async throws -> [Expense] {
        print("Fetching expenses for user: \(forUserID) in category: \(categoryID)")
        let snapshot = try await db.collection("expenses")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .whereField("categoryID", isEqualTo: categoryID.uuidString)
            .getDocuments()
        let expenses = try snapshot.documents.compactMap { try $0.data(as: Expense.self) }
        print("Found \(expenses.count) expenses in category")
        return expenses
    }
}
