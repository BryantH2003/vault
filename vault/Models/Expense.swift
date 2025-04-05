import Foundation
import FirebaseFirestore

/// Represents a user expense in the application
struct Expense: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var categoryID: UUID
    var title: String
    var amount: Double
    var transactionDate: Date
    var vendor: String?
    
    init(id: UUID = UUID(),
         userID: UUID,
         categoryID: UUID,
         title: String,
         amount: Double,
         transactionDate: Date = Date(),
         vendor: String? = nil) {
        self.id = id
        self.userID = userID
        self.categoryID = categoryID
        self.title = title
        self.amount = amount
        self.transactionDate = transactionDate
        self.vendor = vendor
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case categoryID
        case title
        case amount
        case transactionDate
        case vendor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode UUIDs from strings
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }
        
        if let userIDString = try? container.decode(String.self, forKey: .userID) {
            self.userID = UUID(uuidString: userIDString) ?? UUID()
        } else {
            self.userID = try container.decode(UUID.self, forKey: .userID)
        }
        
        if let categoryIDString = try? container.decode(String.self, forKey: .categoryID) {
            self.categoryID = UUID(uuidString: categoryIDString) ?? UUID()
        } else {
            self.categoryID = try container.decode(UUID.self, forKey: .categoryID)
        }
        
        self.title = try container.decode(String.self, forKey: .title)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.transactionDate = try container.decode(Date.self, forKey: .transactionDate)
        self.vendor = try container.decodeIfPresent(String.self, forKey: .vendor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUIDs as strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(userID.uuidString, forKey: .userID)
        try container.encode(categoryID.uuidString, forKey: .categoryID)
        try container.encode(title, forKey: .title)
        try container.encode(amount, forKey: .amount)
        try container.encode(transactionDate, forKey: .transactionDate)
        try container.encodeIfPresent(vendor, forKey: .vendor)
    }
} 
