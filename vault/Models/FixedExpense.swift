import Foundation
import FirebaseFirestore

/// Represents a fixed recurring expense in the application
struct FixedExpense: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var categoryID: UUID
    var title: String
    var amount: Double
    var dueDate: Date
    var transactionDate: Date
    var isRecurring: Bool
    var recurrenceInterval: Int
    var recurringUnit: String
    
    init(
        id: UUID = UUID(),
        userID: UUID,
        categoryID: UUID,
        title: String,
        amount: Double,
        dueDate: Date,
        transactionDate: Date = Date(),
        isRecurring: Bool = true,
        recurrenceInterval: Int,
        recurringUnit: String = "months"
    ) {
        self.id = id
        self.userID = userID
        self.categoryID = categoryID
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.transactionDate = transactionDate
        self.isRecurring = isRecurring
        self.recurrenceInterval = recurrenceInterval
        self.recurringUnit = recurringUnit
    }
    
    enum RecurrenceUnit: String {
        case months = "Months"
        case days = "Days"
        case weeks = "Weeks"
        case years = "Years"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case categoryID
        case title
        case amount
        case dueDate
        case transactionDate
        case isRecurring
        case recurrenceInterval
        case recurringUnit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode UUIDs from strings
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }
        
        if let userIDString = try? container.decode(String.self, forKey: .userID) {
            self.userID = UUID(uuidString: userIDString) ?? UUID()
        } else {
            self.userID = try container.decode(UUID.self, forKey: .userID)
        }
        
        if let categoryIDString = try? container.decode(String.self, forKey: .categoryID) {
            self.categoryID = UUID(uuidString: categoryIDString) ?? UUID()
        } else {
            self.categoryID = try container.decode(UUID.self, forKey: .categoryID)
        }
        
        self.title = try container.decode(String.self, forKey: .title)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.dueDate = try container.decode(Date.self, forKey: .dueDate)
        self.transactionDate = try container.decode(Date.self, forKey: .transactionDate)
        self.isRecurring = try container.decode(Bool.self, forKey: .isRecurring)
        self.recurrenceInterval = try container.decode(Int.self, forKey: .recurrenceInterval)
        self.recurringUnit = try container.decode(String.self, forKey: .recurringUnit)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUIDs as strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(userID.uuidString, forKey: .userID)
        try container.encode(categoryID.uuidString, forKey: .categoryID)
        try container.encode(title, forKey: .title)
        try container.encode(amount, forKey: .amount)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(transactionDate, forKey: .transactionDate)
        try container.encode(isRecurring, forKey: .isRecurring)
        try container.encode(recurrenceInterval, forKey: .recurrenceInterval)
        try container.encode(recurringUnit, forKey: .recurringUnit)
    }
} 
