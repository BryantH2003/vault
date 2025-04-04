import Foundation
import FirebaseFirestore

/// Represents a user expense in the application
struct Expense: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var categoryID: UUID
    var title: String
    var amount: Double
    var transactionDate: Date
    var vendor: String
    
    init(id: UUID = UUID(),
         userID: UUID,
         categoryID: UUID,
         title: String,
         amount: Double,
         transactionDate: Date = Date(),
         vendor: String) {
        self.id = id
        self.userID = userID
        self.categoryID = categoryID
        self.title = title
        self.amount = amount
        self.transactionDate = transactionDate
        self.vendor = vendor
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case categoryID
        case title
        case amount
        case transactionDate
        case vendor
    }
} 
