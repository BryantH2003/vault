//
//  FriendsService.swift
//  vault
//
//  Created by Bryant Huynh on 4/3/25.
//

import Foundation
import CoreData

/// Service for managing Friendship entities
class FriendsService: BaseCoreDataService<FriendshipEntity, Friendship> {
    static let shared = FriendsService(container: CoreDataService.shared.container, entityName: "FriendshipEntity")
    
    override func mapModelToEntity(_ model: Friendship, _ entity: FriendshipEntity) async throws {
        entity.id = model.id
        entity.user1ID = model.user1ID
        entity.user2ID = model.user2ID
        entity.status = model.status
        entity.actionUserID = model.actionUserID
    }
    
    override func mapEntityToModel(_ entity: FriendshipEntity) async throws -> Friendship {
        guard let id = entity.id,
              let user1ID = entity.user1ID,
              let user2ID = entity.user2ID,
              let status = entity.status,
              let actionUserID = entity.actionUserID else {
            throw NSError(domain: "FriendsService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid entity data"])
        }
        
        return Friendship(
            id: id,
            user1ID: user1ID,
            user2ID: user2ID,
            status: status,
            actionUserID: actionUserID
        )
    }
    
    /// Get all friendships for a user
    func getForUser(_ userID: UUID) async throws -> [Friendship] {
        let predicate = NSPredicate(format: "user1ID == %@ OR user2ID == %@", 
                                  userID as CVarArg,
                                  userID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get pending friend requests for a user
    func getPendingRequests(_ userID: UUID) async throws -> [Friendship] {
        let predicate = NSPredicate(format: "(user1ID == %@ OR user2ID == %@) AND status == %@", 
                                  userID as CVarArg,
                                  userID as CVarArg,
                                  "pending" as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get active friendships for a user
    func getActiveFriendships(_ userID: UUID) async throws -> [Friendship] {
        let predicate = NSPredicate(format: "(user1ID == %@ OR user2ID == %@) AND status == %@", 
                                  userID as CVarArg,
                                  userID as CVarArg,
                                  "active" as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
}
