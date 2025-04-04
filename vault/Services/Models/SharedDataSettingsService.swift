//
//  SharedDataSettingsService.swift
//  vault
//
//  Created by Bryant Huynh on 4/3/25.
//

import Foundation
import FirebaseFirestore

/// Service for managing SharedDataSettings entities
class SharedDataSettingsService {
    static let shared = SharedDataSettingsService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("sharedDataSettings").document(id.uuidString)
    }
    
    func createSharedDataSettings(_ settings: SharedDataSettings) async throws -> SharedDataSettings {
        let docRef = documentReference(for: settings.id)
        try docRef.setData(from: settings)
        return settings
    }
    
    func getSharedDataSettings(id: UUID) async throws -> SharedDataSettings? {
        let docRef = documentReference(for: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: SharedDataSettings.self)
    }
    
    func getSharedDataSettings(forUserID: UUID) async throws -> [SharedDataSettings] {
        let snapshot = try await db.collection("sharedDataSettings")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SharedDataSettings.self) }
    }
    
    func getAllSharedDataSettings() async throws -> [SharedDataSettings] {
        let snapshot = try await db.collection("sharedDataSettings").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: SharedDataSettings.self) }
    }
    
    func updateSharedDataSettings(_ settings: SharedDataSettings) async throws -> SharedDataSettings {
        let docRef = documentReference(for: settings.id)
        try docRef.setData(from: settings, merge: true)
        return settings
    }
    
    func deleteSharedDataSettings(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    /// Get shared data settings between two users
    func getSharedDataSettings(userID1: UUID, userID2: UUID) async throws -> SharedDataSettings? {
        let snapshot = try await db.collection("sharedDataSettings")
            .whereField("userID", isEqualTo: userID1.uuidString)
            .whereField("sharedWithUserID", isEqualTo: userID2.uuidString)
            .getDocuments()
        return try snapshot.documents.first.flatMap { try $0.data(as: SharedDataSettings.self) }
    }
}
