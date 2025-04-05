import Foundation

/// Represents a split expense between users in the application
struct SplitExpense: Identifiable, Codable {
    let id: UUID
    var expenseDescription: String
    var totalAmount: Double
    var payerID: UUID
    var creatorID: UUID
    var creationDate: Date
    
    init(id: UUID = UUID(),
         expenseDescription: String,
         totalAmount: Double,
         payerID: UUID,
         creatorID: UUID,
         creationDate: Date = Date()) {
        self.id = id
        self.expenseDescription = expenseDescription
        self.totalAmount = totalAmount
        self.payerID = payerID
        self.creatorID = creatorID
        self.creationDate = creationDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case expenseDescription
        case totalAmount
        case payerID
        case creatorID
        case creationDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode UUIDs from strings
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }
        
        if let payerIDString = try? container.decode(String.self, forKey: .payerID) {
            self.payerID = UUID(uuidString: payerIDString) ?? UUID()
        } else {
            self.payerID = try container.decode(UUID.self, forKey: .payerID)
        }
        
        if let creatorIDString = try? container.decode(String.self, forKey: .creatorID) {
            self.creatorID = UUID(uuidString: creatorIDString) ?? UUID()
        } else {
            self.creatorID = try container.decode(UUID.self, forKey: .creatorID)
        }
        
        self.expenseDescription = try container.decode(String.self, forKey: .expenseDescription)
        self.totalAmount = try container.decode(Double.self, forKey: .totalAmount)
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUIDs as strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(expenseDescription, forKey: .expenseDescription)
        try container.encode(totalAmount, forKey: .totalAmount)
        try container.encode(payerID.uuidString, forKey: .payerID)
        try container.encode(creatorID.uuidString, forKey: .creatorID)
        try container.encode(creationDate, forKey: .creationDate)
    }
} 
