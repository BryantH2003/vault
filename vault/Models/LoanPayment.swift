import Foundation
import FirebaseFirestore

struct LoanPayment: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var title: String
    var totalAmount: Double
    var amountPaid: Double
    var dueDate: Date?
    var notes: String?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    
    var progressPercentage: Double {
        return (amountPaid / totalAmount) * 100
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case totalAmount
        case amountPaid
        case dueDate
        case notes
        case isCompleted
        case createdAt
        case updatedAt
    }
} 