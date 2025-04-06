import Foundation

/// Represents a friendship between two users in the application
struct Friendship: Identifiable, Codable {
    let id: UUID
    var user1ID: UUID
    var user2ID: UUID
    var status: String
    var actionUserID: UUID
    
    init(id: UUID = UUID(),
         user1ID: UUID,
         user2ID: UUID,
         status: String,
         actionUserID: UUID) {
        self.id = id
        self.user1ID = user1ID
        self.user2ID = user2ID
        self.status = status
        self.actionUserID = actionUserID
    }
    
    enum FriendshipStatus: String {
        case pending = "Pending"
        case accepted = "Accepted"
        case blocked = "Blocked"
        case declined = "Declined"
        case removed = "Removed"
        case unknown = "Unknown"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case user1ID
        case user2ID
        case status
        case actionUserID
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode UUIDs from strings
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }
        
        if let user1IDString = try? container.decode(String.self, forKey: .user1ID) {
            self.user1ID = UUID(uuidString: user1IDString) ?? UUID()
        } else {
            self.user1ID = try container.decode(UUID.self, forKey: .user1ID)
        }
        
        if let user2IDString = try? container.decode(String.self, forKey: .user2ID) {
            self.user2ID = UUID(uuidString: user2IDString) ?? UUID()
        } else {
            self.user2ID = try container.decode(UUID.self, forKey: .user2ID)
        }
        
        if let actionUserIDString = try? container.decode(String.self, forKey: .actionUserID) {
            self.actionUserID = UUID(uuidString: actionUserIDString) ?? UUID()
        } else {
            self.actionUserID = try container.decode(UUID.self, forKey: .actionUserID)
        }
        
        self.status = try container.decode(String.self, forKey: .status)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUIDs as strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(user1ID.uuidString, forKey: .user1ID)
        try container.encode(user2ID.uuidString, forKey: .user2ID)
        try container.encode(status, forKey: .status)
        try container.encode(actionUserID.uuidString, forKey: .actionUserID)
    }
} 
