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
        return db.collection("friends").document(id.uuidString)
    }
    
    func addFriend(userID: UUID, friendID: UUID) async throws {
        let docRef = documentReference(for: UUID())
        try await docRef.setData([
            "userID": userID.uuidString,
            "friendID": friendID.uuidString,
            "createdAt": Date()
        ])
    }
    
    func removeFriend(userID: UUID, friendID: UUID) async throws {
        let snapshot = try await db.collection("friends")
            .whereField("userID", isEqualTo: userID.uuidString)
            .whereField("friendID", isEqualTo: friendID.uuidString)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    func getFriends(forUserID: UUID) async throws -> [User] {
        let snapshot = try await db.collection("friends")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        
        var friends: [User] = []
        for document in snapshot.documents {
            if let friendID = UUID(uuidString: document.data()["friendID"] as? String ?? "") {
                if let friend = try await UserService.shared.getUser(id: friendID) {
                    friends.append(friend)
                }
            }
        }
        return friends
    }
    
    func isFriend(userID: UUID, friendID: UUID) async throws -> Bool {
        let snapshot = try await db.collection("friends")
            .whereField("userID", isEqualTo: userID.uuidString)
            .whereField("friendID", isEqualTo: friendID.uuidString)
            .getDocuments()
        return !snapshot.documents.isEmpty
    }
    
    func getMutualFriends(userID1: UUID, userID2: UUID) async throws -> [User] {
        let friends1 = try await getFriends(forUserID: userID1)
        let friends2 = try await getFriends(forUserID: userID2)
        
        let friends1IDs = Set(friends1.map { $0.id })
        return friends2.filter { friends1IDs.contains($0.id) }
    }
}
