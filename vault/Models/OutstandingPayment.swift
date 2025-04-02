import Foundation
import FirebaseFirestore

struct OutstandingPayment: Identifiable, Codable {
    @DocumentID var id: String?
    var uniqueKey: String
    var userId: String
    var title: String
    var totalAmount: Double
    var paidAmount: Double
    var dueDate: Date?
    var category: String
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    var percentageCompleted: Double {
        guard totalAmount > 0 else { return 0 }
        return min((paidAmount / totalAmount) * 100, 100)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case uniqueKey
        case userId
        case title
        case totalAmount
        case paidAmount
        case dueDate
        case category
        case notes
        case createdAt
        case updatedAt
    }
} 
