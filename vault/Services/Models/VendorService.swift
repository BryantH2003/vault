import Foundation
import FirebaseFirestore

/// Service for managing Vendor entities
class VendorService {
    static let shared = VendorService()
    private let db = Firestore.firestore()
    
    private func documentReference(for id: UUID) -> DocumentReference {
        return db.collection("vendors").document(id.uuidString)
    }
    
    func createVendor(_ vendor: Vendor) async throws -> Vendor {
        let docRef = documentReference(for: vendor.id)
        try docRef.setData(from: vendor)
        return vendor
    }
    
    func getVendor(id: UUID) async throws -> Vendor? {
        let docRef = documentReference(for: id)
        let document = try await docRef.getDocument()
        return try? document.data(as: Vendor.self)
    }
    
    func getVendors(forUserID: UUID) async throws -> [Vendor] {
        print("Fetching vendors for user: \(forUserID)")
        let snapshot = try await db.collection("vendors")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .getDocuments()
        let vendors = try snapshot.documents.compactMap { try $0.data(as: Vendor.self) }
        print("Found \(vendors.count) vendors")
        return vendors
    }
    
    func getAllVendors() async throws -> [Vendor] {
        let snapshot = try await db.collection("vendors").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Vendor.self) }
    }
    
    func updateVendor(_ vendor: Vendor) async throws -> Vendor {
        let docRef = documentReference(for: vendor.id)
        try docRef.setData(from: vendor, merge: true)
        return vendor
    }
    
    func deleteVendor(id: UUID) async throws {
        let docRef = documentReference(for: id)
        try await docRef.delete()
    }
    
    /// Get vendors by category
    func getVendors(forCategoryID: UUID) async throws -> [Vendor] {
        print("Fetching vendors for category: \(forCategoryID)")
        let snapshot = try await db.collection("vendors")
            .whereField("categoryID", isEqualTo: forCategoryID.uuidString)
            .getDocuments()
        let vendors = try snapshot.documents.compactMap { try $0.data(as: Vendor.self) }
        print("Found \(vendors.count) vendors in category")
        return vendors
    }
    
    /// Search vendors by name
    func searchVendors(query: String) async throws -> [Vendor] {
        print("Searching vendors with query: \(query)")
        let snapshot = try await db.collection("vendors")
            .whereField("name", isGreaterThanOrEqualTo: query)
            .whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments()
        let vendors = try snapshot.documents.compactMap { try $0.data(as: Vendor.self) }
        print("Found \(vendors.count) vendors matching query")
        return vendors
    }
    
    /// Get frequently used vendors for a user
    func getFrequentVendors(forUserID: UUID, limit: Int = 5) async throws -> [Vendor] {
        print("Fetching frequent vendors for user: \(forUserID)")
        let snapshot = try await db.collection("vendors")
            .whereField("userID", isEqualTo: forUserID.uuidString)
            .order(by: "usageCount", descending: true)
            .limit(to: limit)
            .getDocuments()
        let vendors = try snapshot.documents.compactMap { try $0.data(as: Vendor.self) }
        print("Found \(vendors.count) frequent vendors")
        return vendors
    }
} 