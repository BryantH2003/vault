import Foundation

/// Represents a user's budget in the application
struct Budget: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var categoryID: UUID
    var title: String
    var budgetAmount: Double
    var startDate: Date
    var endDate: Date
    
    init(id: UUID = UUID(),
         userID: UUID,
         categoryID: UUID,
         title: String,
         budgetAmount: Double,
         startDate: Date,
         endDate: Date) {
        self.id = id
        self.userID = userID
        self.categoryID = categoryID
        self.title = title
        self.budgetAmount = budgetAmount
        self.startDate = startDate
        self.endDate = endDate
    }
} 