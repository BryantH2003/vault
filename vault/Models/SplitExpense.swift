import Foundation

/// Represents a split expense between users in the application
struct SplitExpense: Identifiable, Codable, Hashable {
    let id: UUID
    let expenseID: UUID
    var expenseDescription: String
    var totalAmount: Double
    var creatorID: UUID
    var creationDate: Date
    
    init(id: UUID = UUID(),
         expenseID: UUID,
         expenseDescription: String,
         totalAmount: Double,
         creatorID: UUID,
         creationDate: Date = Date()) {
        self.id = id
        self.expenseID = expenseID
        self.expenseDescription = expenseDescription
        self.totalAmount = totalAmount
        self.creatorID = creatorID
        self.creationDate = creationDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case expenseID
        case expenseDescription
        case totalAmount
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
        
        if let expenseIDString = try? container.decode(String.self, forKey: .expenseID) {
            self.expenseID = UUID(uuidString: expenseIDString) ?? UUID()
        } else {
            self.expenseID = try container.decode(UUID.self, forKey: .expenseID)
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
        try container.encode(expenseID.uuidString, forKey: .expenseID)
        try container.encode(expenseDescription, forKey: .expenseDescription)
        try container.encode(totalAmount, forKey: .totalAmount)
        try container.encode(creatorID.uuidString, forKey: .creatorID)
        try container.encode(creationDate, forKey: .creationDate)
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SplitExpense, rhs: SplitExpense) -> Bool {
        lhs.id == rhs.id
    }
} 
