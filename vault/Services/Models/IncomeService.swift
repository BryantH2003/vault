import Foundation
import FirebaseFirestore

/// Service for managing Income entities
class IncomeService {
    static let shared = IncomeService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("incomes").document(id.uuidString)
    }
    
    func createIncome(_ income: Income) async throws -> Income {
        let docRef = documentReference(for: income.id)
        try docRef.setData(from: income)
        return income
    }
    
    func getIncome(id: UUID) async throws -> Income? {
        let docRef = documentReference(for: id)
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
        let docRef = documentReference(for: income.id)
        try docRef.setData(from: income, merge: true)
        return income
    }
    
    func deleteIncome(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    /// Get incomes for a user in a date range
    func getIncomes(forUserID: UUID, in dateRange: ClosedRange<Date>) async throws -> [Income] {
        let snapshot = try await db.collection("incomes")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .whereField("transactionDate", isGreaterThanOrEqualTo: dateRange.lowerBound)
            .whereField("transactionDate", isLessThanOrEqualTo: dateRange.upperBound)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Income.self) }
    }
    
    /// Get total income for a user in a date range
    func getTotalIncome(forUserID: UUID, in dateRange: ClosedRange<Date>) async throws -> Double {
        let incomes = try await getIncomes(forUserID: forUserID, in: dateRange)
        return incomes.reduce(0) { $0 + $1.amount }
    }
}
