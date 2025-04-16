//
//  SplitExpenseService.swift
//  vault
//
//  Created by Bryant Huynh on 4/3/25.
//

import Foundation
import FirebaseFirestore

/// Service for managing SplitExpense entities
class SplitExpenseService {
    static let shared = SplitExpenseService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("splitExpenses").document(id.uuidString)
    }
    
    func createSplitExpense(_ splitExpense: SplitExpense) async throws -> SplitExpense {
        let docRef = documentReference(for: splitExpense.id)
        try docRef.setData(from: splitExpense)
        return splitExpense
    }
    
    func getSplitExpense(id: UUID) async throws -> SplitExpense? {
        let docRef = documentReference(for: id)
        let document = try await docRef.getDocument()
        if let splitExpense = try? document.data(as: SplitExpense.self) {
            // Verify that the returned split expense has the correct ID
            if splitExpense.id == id {
                return splitExpense
            }
        }
        return nil
    }
    
    func getAllSplitExpenses() async throws -> [SplitExpense] {
        let snapshot = try await db.collection("splitExpenses").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SplitExpense.self) }
    }
    
    func updateSplitExpense(_ splitExpense: SplitExpense) async throws -> SplitExpense {
        let docRef = documentReference(for: splitExpense.id)
        try docRef.setData(from: splitExpense, merge: true)
        return splitExpense
    }
    
    func deleteSplitExpense(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
        
        // Delete all participants
        let participantsSnapshot = try await db.collection("splitExpenseParticipants")
            .whereField("expenseID", isEqualTo: id.uuidString)
            .getDocuments()
        
        for document in participantsSnapshot.documents {
            try await document.reference.delete()
        }
    }
    
    func getSplitExpensesUserOwes(forUserID: UUID) async throws -> [SplitExpense] {
        // Get all participant entries for the current user
        let participantsSnapshot = try await db.collection("splitExpenseParticipants")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        
        var splitExpenses: [SplitExpense] = []
        
        print("TEST:", participantsSnapshot.documents[0].data())
        
        // For each participant entry, get the corresponding split expense
        for document in participantsSnapshot.documents {
            if let participant = try? document.data(as: SplitExpenseParticipant.self),
               let splitExpense = try await getSplitExpense(id: participant.splitID) {
                splitExpenses.append(splitExpense)
            }
        }
        
        return splitExpenses
    }
    
    /// Get split expenses where user is a participant
    func getSplitExpensesOthersOweUser(userID: UUID) async throws -> [SplitExpense] {
        // Get expenses where the user is creator
        let creatorSnapshot = try await db.collection("splitExpenses")
            .whereField("creatorID", isEqualTo: userID.uuidString)
            .getDocuments()
        
        return try creatorSnapshot.documents.compactMap { try $0.data(as: SplitExpense.self) }
    }
    
    /// Get unpaid split expenses for a user
    func getUnpaidSplitExpenses(userID: UUID) async throws -> [SplitExpense] {
        let participantsSnapshot = try await db.collection("splitExpenseParticipants")
            .whereField("userID", isEqualTo: userID.uuidString)
            .whereField("hasPaid", isEqualTo: false)
            .getDocuments()
        
        var splitExpenses: [SplitExpense] = []
        for document in participantsSnapshot.documents {
            if let expenseID = UUID(uuidString: document.data()["expenseID"] as? String ?? "") {
                if let splitExpense = try await getSplitExpense(id: expenseID) {
                    splitExpenses.append(splitExpense)
                }

            }
        }
        return splitExpenses
    }
    
    /// Get total amount owed to a user
    func getTotalAmountOwed(toUserID: UUID) async throws -> Double {
        let splitExpenses = try await getSplitExpensesUserOwes(forUserID: toUserID)
        var total = 0.0
        
        for expense in splitExpenses {
            let participants = try await SplitExpenseParticipantService.shared.getUnpaidParticipants(forExpenseID: expense.id)
            total += participants.reduce(into: 0) { $0 + $1.amountDue }
        }
        
        return total
    }
    
    /// Get total amount user owes others
    func getTotalAmountUserOwes(userID: UUID) async throws -> Double {
        let participantsSnapshot = try await db.collection("splitExpenseParticipants")
            .whereField("userID", isEqualTo: userID.uuidString)
            .whereField("hasPaid", isEqualTo: false)
            .getDocuments()
        
        return try participantsSnapshot.documents.reduce(into: 0) { total, document in
            total + (try document.data(as: SplitExpenseParticipant.self).amountDue)
        }
    }
}



