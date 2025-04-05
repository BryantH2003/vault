import Foundation

/// Represents a user's income in the application
struct Income: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var source: String
    var description: String
    var amount: Double
    var transactionDate: Date
    
    init(id: UUID = UUID(),
         userID: UUID,
         source: String,
         description: String,
         amount: Double,
         transactionDate: Date = Date()) {
        self.id = id
        self.userID = userID
        self.source = source
        self.description = description
        self.amount = amount
        self.transactionDate = transactionDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case source
        case description
        case amount
        case transactionDate
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
        
        self.source = try container.decode(String.self, forKey: .source)
        self.description = try container.decode(String.self, forKey: .description)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.transactionDate = try container.decode(Date.self, forKey: .transactionDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUIDs as strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(userID.uuidString, forKey: .userID)
        try container.encode(source, forKey: .source)
        try container.encode(description, forKey: .description)
        try container.encode(amount, forKey: .amount)
        try container.encode(transactionDate, forKey: .transactionDate)
    }
} 