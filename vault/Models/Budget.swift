import Foundation

/// Represents a user's budget in the application
struct Budget: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var categoryID: UUID
    var title: String
    var budgetAmount: Double
    var startDate: Date
    var endDate: Date
    
    init(id: UUID = UUID(),
         userID: UUID,
         categoryID: UUID,
         title: String,
         budgetAmount: Double,
         startDate: Date,
         endDate: Date) {
        self.id = id
        self.userID = userID
        self.categoryID = categoryID
        self.title = title
        self.budgetAmount = budgetAmount
        self.startDate = startDate
        self.endDate = endDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case categoryID
        case title
        case budgetAmount
        case startDate
        case endDate
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
        self.budgetAmount = try container.decode(Double.self, forKey: .budgetAmount)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUIDs as strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(userID.uuidString, forKey: .userID)
        try container.encode(categoryID.uuidString, forKey: .categoryID)
        try container.encode(title, forKey: .title)
        try container.encode(budgetAmount, forKey: .budgetAmount)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
    }
} 