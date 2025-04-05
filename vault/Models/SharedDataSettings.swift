import Foundation

/// Represents data sharing settings between users in the application
struct SharedDataSettings: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var friendID: UUID
    var canViewExpenses: Bool
    var canViewSavings: Bool
    var canViewBudgets: Bool
    
    init(id: UUID = UUID(),
         userID: UUID,
         friendID: UUID,
         canViewExpenses: Bool = false,
         canViewSavings: Bool = false,
         canViewBudgets: Bool = false) {
        self.id = id
        self.userID = userID
        self.friendID = friendID
        self.canViewExpenses = canViewExpenses
        self.canViewSavings = canViewSavings
        self.canViewBudgets = canViewBudgets
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case friendID
        case canViewExpenses
        case canViewSavings
        case canViewBudgets
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
        
        if let friendIDString = try? container.decode(String.self, forKey: .friendID) {
            self.friendID = UUID(uuidString: friendIDString) ?? UUID()
        } else {
            self.friendID = try container.decode(UUID.self, forKey: .friendID)
        }
        
        self.canViewExpenses = try container.decode(Bool.self, forKey: .canViewExpenses)
        self.canViewSavings = try container.decode(Bool.self, forKey: .canViewSavings)
        self.canViewBudgets = try container.decode(Bool.self, forKey: .canViewBudgets)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUIDs as strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(userID.uuidString, forKey: .userID)
        try container.encode(friendID.uuidString, forKey: .friendID)
        try container.encode(canViewExpenses, forKey: .canViewExpenses)
        try container.encode(canViewSavings, forKey: .canViewSavings)
        try container.encode(canViewBudgets, forKey: .canViewBudgets)
    }
} 