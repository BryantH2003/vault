import Foundation
import FirebaseFirestore

/// Represents a user in the application
struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var email: String
    var passwordHash: String
    var fullName: String?
    var registrationDate: Date
    var employmentStatus: String
    var netPaycheckIncome: Double
    var profileImageUrl: String?
    var monthlyIncome: Double
    var monthlySavingsGoal: Double
    var monthlySpendingLimit: Double
    var friends: [String] // Array of friend user IDs
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), 
         username: String, 
         email: String, 
         passwordHash: String, 
         fullName: String? = nil, 
         registrationDate: Date = Date(),
         employmentStatus: String,
         netPaycheckIncome: Double,
         profileImageUrl: String?,
         monthlyIncome: Double,
         monthlySavingsGoal: Double,
         monthlySpendingLimit: Double,
         friends: [String],
         createdAt: Date,
         updatedAt: Date) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.fullName = fullName
        self.registrationDate = registrationDate
        self.employmentStatus = employmentStatus
        self.netPaycheckIncome = netPaycheckIncome
        self.profileImageUrl = profileImageUrl
        self.monthlyIncome = monthlyIncome
        self.monthlySavingsGoal = monthlySavingsGoal
        self.monthlySpendingLimit = monthlySpendingLimit
        self.friends = friends
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case passwordHash
        case fullName
        case registrationDate
        case employmentStatus
        case netPaycheckIncome
        case profileImageUrl
        case monthlyIncome
        case monthlySavingsGoal
        case monthlySpendingLimit
        case friends
        case createdAt
        case updatedAt
    }
} 
