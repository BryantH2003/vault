import Foundation

/// Represents a split expense between users in the application
struct SplitExpense: Identifiable, Codable {
    let id: UUID
    var expenseDescription: String?
    var totalAmount: Double
    var payerID: UUID
    var creationDate: Date
    
    init(id: UUID = UUID(),
         expenseDescription: String? = nil,
         totalAmount: Double,
         payerID: UUID,
         creationDate: Date = Date()) {
        self.id = id
        self.expenseDescription = expenseDescription
        self.totalAmount = totalAmount
        self.payerID = payerID
        self.creationDate = creationDate
    }
} 
