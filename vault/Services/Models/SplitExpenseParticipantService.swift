//
//  SplitExpenseParticipantService.swift
//  vault
//
//  Created by Bryant Huynh on 4/3/25.
//

import Foundation
import FirebaseFirestore

/// Service for managing SplitExpenseParticipant entities
class SplitExpenseParticipantService {
    static let shared = SplitExpenseParticipantService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("splitExpenseParticipants").document(id.uuidString)
    }
    
    func createParticipant(_ participant: SplitExpenseParticipant) async throws -> SplitExpenseParticipant {
        let docRef = documentReference(for: participant.id)
        try docRef.setData(from: participant)
        return participant
    }
    
    func getParticipant(id: UUID) async throws -> SplitExpenseParticipant? {
        let docRef = documentReference(for: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: SplitExpenseParticipant.self)
    }
    
    func getParticipants(forExpenseID: UUID) async throws -> [SplitExpenseParticipant] {
        let snapshot = try await db.collection("splitExpenseParticipants")
            .whereField("expenseID", isEqualTo: forExpenseID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SplitExpenseParticipant.self) }
    }
    
    func getParticipants(forUserID: UUID) async throws -> [SplitExpenseParticipant] {
        let snapshot = try await db.collection("splitExpenseParticipants")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SplitExpenseParticipant.self) }
    }
    
    func getAllParticipants() async throws -> [SplitExpenseParticipant] {
        let snapshot = try await db.collection("splitExpenseParticipants").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SplitExpenseParticipant.self) }
    }
    
    func updateParticipant(_ participant: SplitExpenseParticipant) async throws -> SplitExpenseParticipant {
        let docRef = documentReference(for: participant.id)
        try docRef.setData(from: participant, merge: true)
        return participant
    }
    
    func deleteParticipant(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    /// Get unpaid participants for an expense
    func getUnpaidParticipants(forExpenseID: UUID) async throws -> [SplitExpenseParticipant] {
        let snapshot = try await db.collection("splitExpenseParticipants")
            .whereField("splitID", isEqualTo: forExpenseID.uuidString)
            .whereField("status", isNotEqualTo: "Paid")
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SplitExpenseParticipant.self) }
    }
    
    /// Get paid participants for an expense
    func getPaidParticipants(forExpenseID: UUID) async throws -> [SplitExpenseParticipant] {
        let snapshot = try await db.collection("splitExpenseParticipants")
            .whereField("splitID", isEqualTo: forExpenseID.uuidString)
            .whereField("status", isEqualTo: "Paid")
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SplitExpenseParticipant.self) }
    }
    
    /// Get total amount paid for an expense
    func getTotalAmountPaid(forExpenseID: UUID) async throws -> Double {
        let paidParticipants = try await getPaidParticipants(forExpenseID: forExpenseID)
        return paidParticipants.reduce(into: 0) { $0 + $1.amountDue }
    }
}

