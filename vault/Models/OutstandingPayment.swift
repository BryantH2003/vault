import Foundation
import FirebaseFirestore
import SwiftUI

struct OutstandingPayment: Identifiable, Codable {
    enum Priority: String, Codable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .yellow
            case .low: return .green
            }
        }
    }
    
    let id: UUID
    var userID: UUID
    var categoryID: UUID
    var title: String
    var amount: Double
    var dueDate: Date
    var description: String
    var isPaid: Bool
    var paidDate: Date?
    var priority: Priority
    
    init(
        id: UUID = UUID(),
        userID: UUID,
        categoryID: UUID,
        title: String,
        amount: Double,
        dueDate: Date,
        description: String,
        isPaid: Bool = false,
        paidDate: Date? = nil,
        priority: Priority = .medium
    ) {
        self.id = id
        self.userID = userID
        self.categoryID = categoryID
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.description = description
        self.isPaid = isPaid
        self.paidDate = paidDate
        self.priority = priority
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case categoryID
        case title
        case amount
        case dueDate
        case description
        case isPaid
        case paidDate
        case priority
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
        self.dueDate = try container.decode(Date.self, forKey: .dueDate)
        self.description = try container.decode(String.self, forKey: .description)
        self.isPaid = try container.decode(Bool.self, forKey: .isPaid)
        self.paidDate = try container.decodeIfPresent(Date.self, forKey: .paidDate)
        
        // Handle both string and enum decoding for backward compatibility
        if let priorityString = try? container.decode(String.self, forKey: .priority) {
            self.priority = Priority(rawValue: priorityString) ?? .medium
        } else {
            self.priority = try container.decode(Priority.self, forKey: .priority)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUIDs as strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(userID.uuidString, forKey: .userID)
        try container.encode(categoryID.uuidString, forKey: .categoryID)
        try container.encode(title, forKey: .title)
        try container.encode(amount, forKey: .amount)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(description, forKey: .description)
        try container.encode(isPaid, forKey: .isPaid)
        try container.encodeIfPresent(paidDate, forKey: .paidDate)
        try container.encode(priority, forKey: .priority)
    }
} 
