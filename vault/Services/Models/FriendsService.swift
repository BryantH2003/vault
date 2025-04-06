//
//  FriendsService.swift
//  vault
//
//  Created by Bryant Huynh on 4/3/25.
//

import Foundation
import FirebaseFirestore

/// Service for managing Friend relationships
class FriendsService {
    static let shared = FriendsService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("friendships").document(id.uuidString)
    }
    
    func getFriendships(forUserID: UUID) async throws -> [Friendship] {
        print("Fetching friendships for user: \(forUserID)")
        let snapshot = try await db.collection("friendships")
            .whereField("user1ID", isEqualTo: forUserID.uuidString)
            .getDocuments()
            
        let snapshot2 = try await db.collection("friendships")
            .whereField("user2ID", isEqualTo: forUserID.uuidString)
            .getDocuments()
            
        var friendships = try snapshot.documents.compactMap { try $0.data(as: Friendship.self) }
        friendships.append(contentsOf: try snapshot2.documents.compactMap { try $0.data(as: Friendship.self) })
        
        print("Found \(friendships.count) friendships")
        return friendships
    }
    
    func sendFriendRequest(from userID: UUID, to targetUserID: UUID) async throws -> Friendship {
        let friendship = Friendship(
            user1ID: userID,
            user2ID: targetUserID,
            status: "Pending",
            actionUserID: userID
        )
        
        let docRef = documentReference(for: friendship.id)
        try docRef.setData(from: friendship)
        return friendship
    }
    
    func acceptFriendRequest(_ friendship: Friendship) async throws -> Friendship {
        var updatedFriendship = friendship
        updatedFriendship.status = "Accepted"
        
        let docRef = documentReference(for: friendship.id)
        try docRef.setData(from: updatedFriendship)
        return updatedFriendship
    }
    
    func rejectFriendRequest(_ friendship: Friendship) async throws {
        let docRef = documentReference(for: friendship.id)
        try await docRef.delete()
    }
    
    func removeFriend(_ friendship: Friendship) async throws {
        let docRef = documentReference(for: friendship.id)
        try await docRef.delete()
    }
    
    func getFriendshipStatus(between userID: UUID, and otherUserID: UUID) async throws -> String? {
        let snapshot = try await db.collection("friendships")
            .whereField("user1ID", isEqualTo: userID.uuidString)
            .whereField("user2ID", isEqualTo: otherUserID.uuidString)
            .getDocuments()
            
        let snapshot2 = try await db.collection("friendships")
            .whereField("user1ID", isEqualTo: otherUserID.uuidString)
            .whereField("user2ID", isEqualTo: userID.uuidString)
            .getDocuments()
            
        if let friendship = try snapshot.documents.first.map({ try $0.data(as: Friendship.self) }) {
            return friendship.status
        }
        
        if let friendship = try snapshot2.documents.first.map({ try $0.data(as: Friendship.self) }) {
            return friendship.status
        }
        
        return nil
    }
}
