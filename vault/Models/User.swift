import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var uniqueKey: String  // Unique identifier
    var email: String
    var fullName: String
    var profileImageUrl: String?
    var monthlyIncome: Double
    var monthlySavingsGoal: Double
    var monthlySpendingLimit: Double
    var friends: [String] // Array of friend user IDs
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case uniqueKey
        case email
        case fullName
        case profileImageUrl
        case monthlyIncome
        case monthlySavingsGoal
        case monthlySpendingLimit
        case friends
        case createdAt
        case updatedAt
    }
} 