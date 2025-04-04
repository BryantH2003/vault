import Foundation

/// Represents an expense category in the application
struct Category: Identifiable, Codable {
    let id: UUID
    var categoryName: String
    var fixedExpense: Bool
    
    init(id: UUID = UUID(),
         categoryName: String,
         fixedExpense: Bool = false) {
        self.id = id
        self.categoryName = categoryName
        self.fixedExpense = fixedExpense
    }
} 