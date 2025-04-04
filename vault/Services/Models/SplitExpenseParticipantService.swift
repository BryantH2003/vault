//
//  SplitExpenseParticipantService.swift
//  vault
//
//  Created by Bryant Huynh on 4/3/25.
//

import Foundation
import CoreData

/// Service for managing Split Expense Participant entities
class SplitExpenseParticipantService: BaseCoreDataService<SplitExpenseParticipantEntity, SplitExpenseParticipant> {
    static let shared = SplitExpenseParticipantService(container: CoreDataService.shared.container, entityName: "SplitExpenseParticipantEntity")
    
    override func mapModelToEntity(_ model: SplitExpenseParticipant, _ entity: SplitExpenseParticipantEntity) async throws {
        entity.id = model.id
        entity.splitID = model.splitID
        entity.userID = model.userID
        entity.amountDue = model.amountDue
        entity.status = model.status
    }
    
    override func mapEntityToModel(_ entity: SplitExpenseParticipantEntity) async throws -> SplitExpenseParticipant {
        guard let id = entity.id,
              let splitID = entity.splitID,
              let userID = entity.userID,
              let status = entity.status else {
            throw NSError(domain: "SplitExpenseParticipantService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid entity data"])
        }
        
        return SplitExpenseParticipant(
            id: id,
            splitID: splitID,
            userID: userID,
            amountDue: entity.amountDue,
            status: status
        )
    }
    
    /// Get participants for a split expense
    func getForSplit(_ splitID: UUID) async throws -> [SplitExpenseParticipant] {
        let predicate = NSPredicate(format: "splitID == %@", splitID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get all split expenses where a user is a participant
    func getForUser(_ userID: UUID) async throws -> [SplitExpenseParticipant] {
        let predicate = NSPredicate(format: "userID == %@", userID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get pending split expenses for a user
    func getPendingForUser(_ userID: UUID) async throws -> [SplitExpenseParticipant] {
        let predicate = NSPredicate(format: "userID == %@ AND status == %@", 
                                  userID as CVarArg,
                                  "pending" as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get all participants for a split expense
    func getSplitExpenseParticipants(forSplitID: UUID) async throws -> [SplitExpenseParticipant] {
        return try await getForSplit(forSplitID)
    }
}

