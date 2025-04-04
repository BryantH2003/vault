import Foundation

/// Represents a user's income in the application
struct Income: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var source: String
    var description: String
    var amount: Double
    var transactionDate: Date
    
    init(id: UUID = UUID(),
         userID: UUID,
         source: String,
         description: String,
         amount: Double,
         transactionDate: Date = Date()) {
        self.id = id
        self.userID = userID
        self.source = source
        self.description = description
        self.amount = amount
        self.transactionDate = transactionDate
    }
} 