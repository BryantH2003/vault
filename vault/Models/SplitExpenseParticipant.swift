import Foundation

/// Represents a participant in a split expense in the application
struct SplitExpenseParticipant: Identifiable, Codable {
    let id: UUID
    var splitID: UUID
    var userID: UUID
    var amountDue: Double
    var status: String
    
    init(id: UUID = UUID(),
         splitID: UUID,
         userID: UUID,
         amountDue: Double,
         status: String = "Pending") {
        self.id = id
        self.splitID = splitID
        self.userID = userID
        self.amountDue = amountDue
        self.status = status
    }
    
    enum PaymentStatus: String {
        case pending = "Pending"
        case accepted = "Accepted"
        case declined = "Declined"
        case paid = "Paid"
    }
} 