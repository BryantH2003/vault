import Foundation
import FirebaseFirestore

struct Expense: Identifiable, Codable {
    @DocumentID var id: String?
    var uniqueKey: String  // Unique identifier
    var userId: String
    var amount: Double
    var category: String
    var description: String
    var date: Date
    var isRecurring: Bool
    var recurringInterval: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uniqueKey
        case userId
        case amount
        case category
        case description
        case date
        case isRecurring
        case recurringInterval
    }
} 
