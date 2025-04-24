import Foundation
import FirebaseFirestore

/// Service for managing SavingsGoal entities
class SavingsGoalService: SavingsGoalServiceProtocol {
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("savingsGoals").document(id.uuidString)
    }
    
    func getSavingsGoals(forUserID: UUID) async throws -> [SavingsGoal] {
        print("Fetching savings goals for user: \(forUserID)")
        let snapshot = try await db.collection("savingsGoals")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        let goals = try snapshot.documents.compactMap { try $0.data(as: SavingsGoal.self) }
        print("Found \(goals.count) savings goals")
        return goals
    }
    
    func createSavingsGoal(_ goal: SavingsGoal, forUserID: UUID) async throws {
        let docRef = documentReference(for: goal.id)
        try docRef.setData(from: goal)
    }
    
    func updateSavingsGoal(_ goal: SavingsGoal) async throws {
        let docRef = documentReference(for: goal.id)
        try docRef.setData(from: goal, merge: true)
    }
    
    func deleteSavingsGoal(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
} 