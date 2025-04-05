import Foundation

/// Represents a participant in a split expense in the application
struct SplitExpenseParticipant: Identifiable, Codable {
    let id: UUID
    var splitID: UUID
    var userID: UUID
    var amountDue: Double
    var status: String
    
    init(id: UUID = UUID(),
         splitID: UUID,
         userID: UUID,
         amountDue: Double,
         status: String = "Pending") {
        self.id = id
        self.splitID = splitID
        self.userID = userID
        self.amountDue = amountDue
        self.status = status
    }
    
    enum PaymentStatus: String {
        case pending = "Pending"
        case accepted = "Accepted"
        case declined = "Declined"
        case paid = "Paid"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case splitID
        case userID
        case amountDue
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode UUIDs from strings
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }
        
        if let splitIDString = try? container.decode(String.self, forKey: .splitID) {
            self.splitID = UUID(uuidString: splitIDString) ?? UUID()
        } else {
            self.splitID = try container.decode(UUID.self, forKey: .splitID)
        }
        
        if let userIDString = try? container.decode(String.self, forKey: .userID) {
            self.userID = UUID(uuidString: userIDString) ?? UUID()
        } else {
            self.userID = try container.decode(UUID.self, forKey: .userID)
        }
        
        self.amountDue = try container.decode(Double.self, forKey: .amountDue)
        self.status = try container.decode(String.self, forKey: .status)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUIDs as strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(splitID.uuidString, forKey: .splitID)
        try container.encode(userID.uuidString, forKey: .userID)
        try container.encode(amountDue, forKey: .amountDue)
        try container.encode(status, forKey: .status)
    }
} 