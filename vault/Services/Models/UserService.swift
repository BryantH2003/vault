import Foundation
import FirebaseFirestore

/// Service for managing User entities
class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("users").document(id.uuidString)
    }
    
    func createUser(_ user: User) async throws -> User {
        let docRef = documentReference(for: user.id)
        try docRef.setData(from: user)
        return user
    }
    
    func getUser(id: UUID) async throws -> User? {
        let docRef = documentReference(for: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: User.self)
    }
    
    func getAllUsers() async throws -> [User] {
        let snapshot = try await db.collection("users").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: User.self) }
    }
    
    func updateUser(_ user: User) async throws -> User {
        let docRef = documentReference(for: user.id)
        try docRef.setData(from: user, merge: true)
        return user
    }
    
    func deleteUser(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    /// Get user by email
    func getByEmail(_ email: String) async throws -> User? {
        let snapshot = try await db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()
        return try snapshot.documents.first.flatMap { try $0.data(as: User.self) }
    }
    
    /// Get user by username
    func getByUsername(_ username: String) async throws -> User? {
        let snapshot = try await db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()
        return try snapshot.documents.first.flatMap { try $0.data(as: User.self) }
    }
    
    func searchUsers(query: String) async throws -> [User] {
        print("Searching users with query: \(query)")
        let lowercaseQuery = query.lowercased()
        
        // Search by username
        let snapshot = try await db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: lowercaseQuery)
            .whereField("username", isLessThanOrEqualTo: lowercaseQuery + "\u{f8ff}")
            .getDocuments()
        
        // Search by email
        let snapshot2 = try await db.collection("users")
            .whereField("email", isGreaterThanOrEqualTo: lowercaseQuery)
            .whereField("email", isLessThanOrEqualTo: lowercaseQuery + "\u{f8ff}")
            .getDocuments()
        
        // Search by full name
        let snapshot3 = try await db.collection("users")
            .whereField("fullName", isGreaterThanOrEqualTo: lowercaseQuery)
            .whereField("fullName", isLessThanOrEqualTo: lowercaseQuery + "\u{f8ff}")
            .getDocuments()
        
        // Use Dictionary to handle duplicates by ID
        var userDict: [UUID: User] = [:]
        
        // Combine results from all searches
        for document in snapshot.documents + snapshot2.documents + snapshot3.documents {
            if let user = try? document.data(as: User.self) {
                userDict[user.id] = user
            }
        }
        
        print("Found \(userDict.count) users matching query")
        return Array(userDict.values)
    }
}
