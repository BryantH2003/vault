import Foundation
import FirebaseFirestore

/// Service for managing SavingsGoal entities
class SavingsGoalService {
    static let shared = SavingsGoalService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("savingsGoals").document(id.uuidString)
    }
    
    func createSavingsGoal(_ savingsGoal: SavingsGoal) async throws -> SavingsGoal {
        let docRef = documentReference(for: savingsGoal.id)
        try docRef.setData(from: savingsGoal)
        return savingsGoal
    }
    
    func getSavingsGoal(id: UUID) async throws -> SavingsGoal? {
        let docRef = documentReference(for: id)
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
        let docRef = documentReference(for: savingsGoal.id)
        try docRef.setData(from: savingsGoal, merge: true)
        return savingsGoal
    }
    
    func deleteSavingsGoal(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    /// Get active savings goals for a user
    func getActiveSavingsGoals(forUserID: UUID) async throws -> [SavingsGoal] {
        let now = Date()
        let snapshot = try await db.collection("savingsGoals")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .whereField("targetDate", isGreaterThanOrEqualTo: now)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SavingsGoal.self) }
    }
    
    /// Get completed savings goals for a user
    func getCompletedSavingsGoals(forUserID: UUID) async throws -> [SavingsGoal] {
        let snapshot = try await db.collection("savingsGoals")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .whereField("currentAmount", isGreaterThanOrEqualTo: "targetAmount")
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SavingsGoal.self) }
    }
}
