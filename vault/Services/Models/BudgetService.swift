import Foundation
import FirebaseFirestore

/// Service for managing Budget entities
class BudgetService {
    static let shared = BudgetService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("budgets").document(id.uuidString)
    }
    
    func createBudget(_ budget: Budget) async throws -> Budget {
        let docRef = documentReference(for: budget.id)
        try docRef.setData(from: budget)
        return budget
    }
    
    func getBudget(id: UUID) async throws -> Budget? {
        let docRef = documentReference(for: id)
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
        let docRef = documentReference(for: budget.id)
        try docRef.setData(from: budget, merge: true)
        return budget
    }
    
    func deleteBudget(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    /// Get budgets for a user in a date range
    func getBudgets(forUserID: UUID, in dateRange: ClosedRange<Date>) async throws -> [Budget] {
        let snapshot = try await db.collection("budgets")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .whereField("startDate", isGreaterThanOrEqualTo: dateRange.lowerBound)
            .whereField("endDate", isLessThanOrEqualTo: dateRange.upperBound)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Budget.self) }
    }
    
    /// Get budgets for a user and category
    func getBudgets(forUserID: UUID, categoryID: UUID) async throws -> [Budget] {
        let snapshot = try await db.collection("budgets")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .whereField("categoryID", isEqualTo: categoryID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Budget.self) }
    }
    
    /// Get active budgets for a user
    func getActiveBudgets(forUserID: UUID) async throws -> [Budget] {
        let now = Date()
        let snapshot = try await db.collection("budgets")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .whereField("startDate", isLessThanOrEqualTo: now)
            .whereField("endDate", isGreaterThanOrEqualTo: now)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Budget.self) }
    }
}
