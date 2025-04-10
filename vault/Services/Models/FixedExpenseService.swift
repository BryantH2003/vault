import Foundation
import FirebaseFirestore

/// Service for managing FixedExpense entities
class FixedExpenseService {
    static let shared = FixedExpenseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("fixedExpenses").document(id.uuidString)
    }
    
    // MARK: - Create Operations
    
    func createFixedExpense(_ expense: FixedExpense) async throws -> FixedExpense {
        let docRef = documentReference(for: expense.id)
        try docRef.setData(from: expense)
        return expense
    }
    
    // MARK: - Read Operations
    
    func getFixedExpense(id: UUID) async throws -> FixedExpense? {
        let docRef = documentReference(for: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: FixedExpense.self)
    }
    
    func getAllFixedExpenses() async throws -> [FixedExpense] {
        let snapshot = try await db.collection("fixedExpenses").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FixedExpense.self) }
    }
    
    func getFixedExpenses(forUserID userID: UUID) async throws -> [FixedExpense] {
        let snapshot = try await db.collection("fixedExpenses")
            .whereField("userID", isEqualTo: userID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FixedExpense.self) }
    }
    
    func getFixedExpenses(forUserID userID: UUID, in dateRange: ClosedRange<Date>) async throws -> [FixedExpense] {
        let snapshot = try await db.collection("fixedExpenses")
            .whereField("userID", isEqualTo: userID.uuidString)
            .whereField("dueDate", isGreaterThanOrEqualTo: dateRange.lowerBound)
            .whereField("dueDate", isLessThanOrEqualTo: dateRange.upperBound)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FixedExpense.self) }
    }
    
    func getFixedExpenses(forUserID userID: UUID, categoryID: UUID) async throws -> [FixedExpense] {
        let snapshot = try await db.collection("fixedExpenses")
            .whereField("userID", isEqualTo: userID.uuidString)
            .whereField("categoryID", isEqualTo: categoryID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FixedExpense.self) }
    }
    
    func getUpcomingFixedExpenses(forUserID userID: UUID, limit: Int = 5) async throws -> [FixedExpense] {
        let snapshot = try await db.collection("fixedExpenses")
            .whereField("userID", isEqualTo: userID.uuidString)
            .whereField("dueDate", isGreaterThanOrEqualTo: Date())
            .order(by: "dueDate")
            .limit(to: limit)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FixedExpense.self) }
    }
    
    func getOverdueFixedExpenses(forUserID userID: UUID) async throws -> [FixedExpense] {
        let snapshot = try await db.collection("fixedExpenses")
            .whereField("userID", isEqualTo: userID.uuidString)
            .whereField("dueDate", isLessThan: Date())
            .order(by: "dueDate", descending: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FixedExpense.self) }
    }
    
    // MARK: - Update Operations
    
    func updateFixedExpense(_ expense: FixedExpense) async throws -> FixedExpense {
        let docRef = documentReference(for: expense.id)
        try docRef.setData(from: expense, merge: true)
        return expense
    }
    
    func updateDueDate(id: UUID, newDueDate: Date) async throws {
        let docRef = documentReference(for: id)
        try await docRef.updateData([
            "dueDate": newDueDate
        ])
    }
    
    func updateAmount(id: UUID, newAmount: Double) async throws {
        let docRef = documentReference(for: id)
        try await docRef.updateData([
            "amount": newAmount
        ])
    }
    
    func updateRecurringStatus(id: UUID, isRecurring: Bool, frequency: String?) async throws {
        let docRef = documentReference(for: id)
        var data: [String: Any] = ["isRecurring": isRecurring]
        if let frequency = frequency {
            data["recurringFrequency"] = frequency
        }
        try await docRef.updateData(data)
    }
    
    // MARK: - Delete Operations
    
    func deleteFixedExpense(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    func deleteAllFixedExpenses(forUserID userID: UUID) async throws {
        let batch = db.batch()
        let snapshot = try await db.collection("fixedExpenses")
            .whereField("userID", isEqualTo: userID.uuidString)
            .getDocuments()
        
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        
        try await batch.commit()
    }
    
    // MARK: - Helper Methods
    
    func calculateTotalAmount(forUserID userID: UUID, in dateRange: ClosedRange<Date>) async throws -> Double {
        let expenses = try await getFixedExpenses(forUserID: userID, in: dateRange)
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    func calculateTotalAmountByCategory(forUserID userID: UUID, in dateRange: ClosedRange<Date>) async throws -> [UUID: Double] {
        let expenses = try await getFixedExpenses(forUserID: userID, in: dateRange)
        return Dictionary(grouping: expenses, by: { $0.categoryID })
            .mapValues { expenses in expenses.reduce(0) { $0 + $1.amount } }
    }
} 