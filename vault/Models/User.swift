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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode UUID from string
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }
        
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
        self.passwordHash = try container.decode(String.self, forKey: .passwordHash)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.registrationDate = try container.decode(Date.self, forKey: .registrationDate)
        self.employmentStatus = try container.decode(String.self, forKey: .employmentStatus)
        self.netPaycheckIncome = try container.decode(Double.self, forKey: .netPaycheckIncome)
        self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        self.monthlyIncome = try container.decode(Double.self, forKey: .monthlyIncome)
        self.monthlySavingsGoal = try container.decode(Double.self, forKey: .monthlySavingsGoal)
        self.monthlySpendingLimit = try container.decode(Double.self, forKey: .monthlySpendingLimit)
        self.friends = try container.decode([String].self, forKey: .friends)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUID as string
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(passwordHash, forKey: .passwordHash)
        try container.encodeIfPresent(fullName, forKey: .fullName)
        try container.encode(registrationDate, forKey: .registrationDate)
        try container.encode(employmentStatus, forKey: .employmentStatus)
        try container.encode(netPaycheckIncome, forKey: .netPaycheckIncome)
        try container.encodeIfPresent(profileImageUrl, forKey: .profileImageUrl)
        try container.encode(monthlyIncome, forKey: .monthlyIncome)
        try container.encode(monthlySavingsGoal, forKey: .monthlySavingsGoal)
        try container.encode(monthlySpendingLimit, forKey: .monthlySpendingLimit)
        try container.encode(friends, forKey: .friends)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
} 
