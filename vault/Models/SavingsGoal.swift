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
} 