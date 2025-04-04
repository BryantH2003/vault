import Foundation

/// Represents a fixed recurring expense in the application
struct FixedExpense: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var categoryID: UUID
    var title: String
    var amount: Double
    var dueDate: Date
    var transactionDate: Date
    
    init(id: UUID = UUID(),
         userID: UUID,
         categoryID: UUID,
         title: String,
         amount: Double,
         dueDate: Date,
         transactionDate: Date = Date()) {
        self.id = id
        self.userID = userID
        self.categoryID = categoryID
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.transactionDate = transactionDate
    }
} 