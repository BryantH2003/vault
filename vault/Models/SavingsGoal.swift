import Foundation

/// Represents a user's savings goal in the application
struct SavingsGoal: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var goalName: String
    var targetAmount: Double
    var currentAmount: Double
    var targetDate: Date?
    var creationDate: Date
    
    init(id: UUID = UUID(),
         userID: UUID,
         goalName: String,
         targetAmount: Double,
         currentAmount: Double = 0.0,
         targetDate: Date? = nil,
         creationDate: Date = Date()) {
        self.id = id
        self.userID = userID
        self.goalName = goalName
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.creationDate = creationDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case goalName
        case targetAmount
        case currentAmount
        case targetDate
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
        
        if let userIDString = try? container.decode(String.self, forKey: .userID) {
            self.userID = UUID(uuidString: userIDString) ?? UUID()
        } else {
            self.userID = try container.decode(UUID.self, forKey: .userID)
        }
        
        self.goalName = try container.decode(String.self, forKey: .goalName)
        self.targetAmount = try container.decode(Double.self, forKey: .targetAmount)
        self.currentAmount = try container.decode(Double.self, forKey: .currentAmount)
        self.targetDate = try container.decodeIfPresent(Date.self, forKey: .targetDate)
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUIDs as strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(userID.uuidString, forKey: .userID)
        try container.encode(goalName, forKey: .goalName)
        try container.encode(targetAmount, forKey: .targetAmount)
        try container.encode(currentAmount, forKey: .currentAmount)
        try container.encodeIfPresent(targetDate, forKey: .targetDate)
        try container.encode(creationDate, forKey: .creationDate)
    }
} 