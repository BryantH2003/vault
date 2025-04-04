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
    }
} 