import Foundation
import FirebaseFirestore

/// Service for managing Category entities
class CategoryService {
    static let shared = CategoryService()
    private let db = Firestore.firestore()
    
    enum CategoryError: Error {
        case notFound
        case decodingError
    }
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("categories").document(id.uuidString)
    }
    
    func createCategory(_ category: Category) async throws -> Category {
        let docRef = documentReference(for: category.id)
        try docRef.setData(from: category)
        return category
    }
    
    func getCategoryByID(id: UUID) async throws -> Category? {
        let docRef = documentReference(for: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: Category.self)
    }
    
    func getCategoryByName(name: String) async throws -> Category {
        let snapshot = try await db.collection("categories")
            .whereField("categoryName", isEqualTo: name)
            .getDocuments()
        
        if let document = snapshot.documents.first {
            do {
                let category = try document.data(as: Category.self)
                return category
            } catch {
                print("Error decoding category: \(error)")
                throw CategoryError.decodingError
            }
        } else {
            throw CategoryError.notFound
        }
    }
    
    func getCategories(forUserID: UUID) async throws -> [Category] {
        let snapshot = try await db.collection("categories")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Category.self) }
    }
    
    func getAllCategories() async throws -> [Category] {
        let snapshot = try await db.collection("categories").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Category.self) }
    }
    
    func updateCategory(_ category: Category) async throws -> Category {
        let docRef = documentReference(for: category.id)
        try docRef.setData(from: category, merge: true)
        return category
    }
    
    func deleteCategory(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    /// Get default categories
    func getDefaultCategories() async throws -> [Category] {
        let snapshot = try await db.collection("categories")
            .whereField("isDefault", isEqualTo: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Category.self) }
    }
}
