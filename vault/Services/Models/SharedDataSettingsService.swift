//
//  SharedDataSettingsService.swift
//  vault
//
//  Created by Bryant Huynh on 4/3/25.
//

import Foundation
import CoreData

/// Service for managing Shared Data Settings entities
class SharedDataSettingsService: BaseCoreDataService<SharedDataSettingsEntity, SharedDataSettings> {
    static let shared = SharedDataSettingsService(container: CoreDataService.shared.container, entityName: "SharedDataSettingsEntity")
    
    override func mapModelToEntity(_ model: SharedDataSettings, _ entity: SharedDataSettingsEntity) async throws {
        entity.id = model.id
        entity.userID = model.userID
        entity.friendID = model.friendID
        entity.canViewExpenses = model.canViewExpenses
        entity.canViewSavings = model.canViewSavings
        entity.canViewBudgets = model.canViewBudgets
    }
    
    override func mapEntityToModel(_ entity: SharedDataSettingsEntity) async throws -> SharedDataSettings {
        guard let id = entity.id,
              let userID = entity.userID,
              let friendID = entity.friendID else {
            throw NSError(domain: "SharedDataSettingsService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid entity data"])
        }
        
        return SharedDataSettings(
            id: id,
            userID: userID,
            friendID: friendID,
            canViewExpenses: entity.canViewExpenses,
            canViewSavings: entity.canViewSavings,
            canViewBudgets: entity.canViewBudgets
        )
    }
    
    /// Get shared data settings for a user
    func getForUser(_ userID: UUID) async throws -> [SharedDataSettings] {
        let predicate = NSPredicate(format: "userID == %@", userID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get shared data settings between two users
    func getSettingsBetweenUsers(_ userID: UUID, _ friendID: UUID) async throws -> SharedDataSettings? {
        let predicate = NSPredicate(format: "userID == %@ AND friendID == %@", 
                                  userID as CVarArg,
                                  friendID as CVarArg)
        let settings = try await getAllWithPredicate(predicate)
        return settings.first
    }
}
