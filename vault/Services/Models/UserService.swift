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
}
