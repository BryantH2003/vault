import Foundation
import FirebaseFirestore

/// Service for managing OutstandingPayment entities
class OutstandingService {
    static let shared = OutstandingService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("outstandingPayments").document(id.uuidString)
    }
    
    func createOutstandingPayment(_ payment: OutstandingPayment) async throws -> OutstandingPayment {
        let docRef = documentReference(for: payment.id)
        try docRef.setData(from: payment)
        return payment
    }
    
    func getOutstandingPayment(id: UUID) async throws -> OutstandingPayment? {
        let docRef = documentReference(for: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: OutstandingPayment.self)
    }
    
    func getOutstandingPayments(forUserID: UUID) async throws -> [OutstandingPayment] {
        print("Fetching outstanding payments for user: \(forUserID)")
        let snapshot = try await db.collection("outstandingPayments")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        let payments = try snapshot.documents.compactMap { try $0.data(as: OutstandingPayment.self) }
        print("Found \(payments.count) outstanding payments")
        return payments
    }
    
    func getAllOutstandingPayments() async throws -> [OutstandingPayment] {
        let snapshot = try await db.collection("outstandingPayments").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: OutstandingPayment.self) }
    }
    
    func updateOutstandingPayment(_ payment: OutstandingPayment) async throws -> OutstandingPayment {
        let docRef = documentReference(for: payment.id)
        try docRef.setData(from: payment, merge: true)
        return payment
    }
    
    func deleteOutstandingPayment(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    /// Get outstanding payments by category
    func getOutstandingPayments(forCategoryID: UUID) async throws -> [OutstandingPayment] {
        print("Fetching outstanding payments for category: \(forCategoryID)")
        let snapshot = try await db.collection("outstandingPayments")
            .whereField("categoryID", isEqualTo: forCategoryID.uuidString)
            .getDocuments()
        let payments = try snapshot.documents.compactMap { try $0.data(as: OutstandingPayment.self) }
        print("Found \(payments.count) outstanding payments in category")
        return payments
    }
    
    /// Get total outstanding amount for a user
    func getTotalOutstandingAmount(forUserID: UUID) async throws -> Double {
        let payments = try await getOutstandingPayments(forUserID: forUserID)
        return payments.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    /// Get overdue outstanding payments
    func getOverduePayments(forUserID: UUID) async throws -> [OutstandingPayment] {
        let payments = try await getOutstandingPayments(forUserID: forUserID)
        let currentDate = Date()
        return payments.filter { !$0.isPaid && $0.dueDate < currentDate }
    }
    
    /// Mark outstanding payment as paid
    func markAsPaid(_ payment: OutstandingPayment) async throws -> OutstandingPayment {
        var updatedPayment = payment
        updatedPayment.isPaid = true
        updatedPayment.paidDate = Date()
        return try await updateOutstandingPayment(updatedPayment)
    }
    
    /// Get upcoming payments
    func getUpcomingPayments(forUserID: UUID, days: Int = 7) async throws -> [OutstandingPayment] {
        let payments = try await getOutstandingPayments(forUserID: forUserID)
        let currentDate = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) ?? currentDate
        
        return payments.filter {
            !$0.isPaid && $0.dueDate > currentDate && $0.dueDate <= futureDate
        }
    }
} 
