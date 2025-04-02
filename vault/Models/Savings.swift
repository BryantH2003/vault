import Foundation
import FirebaseFirestore

struct Savings: Identifiable, Codable {
    @DocumentID var id: String?
    var uniqueKey: String  // Unique identifier
    var userId: String
    var month: Int  // 1-12
    var year: Int
    var amount: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case uniqueKey
        case userId
        case month
        case year
        case amount
    }
} 
