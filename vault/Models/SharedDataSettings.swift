import Foundation

/// Represents data sharing settings between users in the application
struct SharedDataSettings: Identifiable, Codable {
    let id: UUID
    var userID: UUID
    var friendID: UUID
    var canViewExpenses: Bool
    var canViewSavings: Bool
    var canViewBudgets: Bool
    
    init(id: UUID = UUID(),
         userID: UUID,
         friendID: UUID,
         canViewExpenses: Bool = false,
         canViewSavings: Bool = false,
         canViewBudgets: Bool = false) {
        self.id = id
        self.userID = userID
        self.friendID = friendID
        self.canViewExpenses = canViewExpenses
        self.canViewSavings = canViewSavings
        self.canViewBudgets = canViewBudgets
    }
} 