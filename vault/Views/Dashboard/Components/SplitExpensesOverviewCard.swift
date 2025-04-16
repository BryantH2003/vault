import SwiftUI

struct SplitExpensesOverviewCard: View {
    let expensesYouOwe: [SplitExpense]
    let expensesOwedToYou: [SplitExpense]
    let participants: [UUID: [SplitExpenseParticipant]]
    let splitExpenses: [(expense: SplitExpense, participants: [SplitExpenseParticipant])]
    let isLoading: Bool
    let users: [UUID: User]
    let currentUserID: UUID
    
    private var totalYouOwe: Double {
            var total = 0.0
            for expense in expensesYouOwe {
                if let participant = participants[expense.id]?.first(where: { $0.userID == currentUserID }) {
                    total += participant.amountDue
                }
            }
            return total
        }
        
    private var totalOwedToYou: Double {
        var total = 0.0
        for expense in expensesOwedToYou {
            if let participantList = participants[expense.id] {
                for participant in participantList {
                    total += participant.amountDue
                }
            }
        }
        return total
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SplitExpensesSection (
                splitExpenses: splitExpenses,
                isLoading: isLoading,
                currentUserID: currentUserID)
        }
    }
}

private struct SplitExpenseRow: View {
    let title: String
    let fullName: String
    let amount: Double
    let date: Date
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .cardRowTitleStyle()
                
                Spacer()
                
                Text(amount, format: .currency(code: "USD"))
                    .cardRowAmountStyle()
            }
            
            HStack {
                Text(fullName)
                    .secondaryTitleStyle()
                
                Spacer()
                
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .secondaryTitleStyle()
            }
        }
    }
} 
