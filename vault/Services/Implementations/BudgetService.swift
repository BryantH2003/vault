import Foundation
import FirebaseFirestore

/// Service for managing Budget entities
class BudgetService: BudgetServiceProtocol {
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("budgets").document(id.uuidString)
    }
    
    func getBudgets(forUserID: UUID) async throws -> [Budget] {
        print("Fetching budgets for user: \(forUserID)")
        let snapshot = try await db.collection("budgets")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        let budgets = try snapshot.documents.compactMap { try $0.data(as: Budget.self) }
        print("Found \(budgets.count) budgets")
        return budgets
    }
    
    func createBudget(_ budget: Budget, forUserID: UUID) async throws {
        let docRef = documentReference(for: budget.id)
        try docRef.setData(from: budget)
    }
    
    func updateBudget(_ budget: Budget) async throws {
        let docRef = documentReference(for: budget.id)
        try docRef.setData(from: budget, merge: true)
    }
    
    func deleteBudget(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
} 