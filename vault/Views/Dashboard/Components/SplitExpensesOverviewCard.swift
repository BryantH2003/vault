import SwiftUI

struct SplitExpensesOverviewCard: View {
    let expensesYouOwe: [SplitExpense]
    let expensesOwedToYou: [SplitExpense]
    let participants: [UUID: [SplitExpenseParticipant]]
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
            VStack(alignment: .leading, spacing: 12) {
                Text("People You Owe")
                    .cardTitleStyle()
                if !expensesYouOwe.isEmpty {
                        
                    Text(totalYouOwe, format: .currency(code: "USD"))
                        .figtreeFont(.semibold, size: 20)
                        .foregroundColor(.primary)
                    
                    ForEach(expensesYouOwe, id: \.id) { expense in
                        if let participantsList = participants[expense.id] {
                            ForEach(participantsList, id: \.id) { participant in
                                if let user = users[expense.creatorID] {
                                    SplitExpenseRow(
                                        title: expense.expenseDescription,
                                        fullName: user.fullName ?? user.username,
                                        amount: participant.amountDue,
                                        date: expense.creationDate
                                    )
                                }
                            }
                        }
                    }

                } else {
                    Text("You currently owe no one")
                        .font(.caption)
                        .figtreeFont(.medium, size: 12)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("People that Owe You")
                    .cardTitleStyle()
            
                if !expensesOwedToYou.isEmpty {
                                    
                    Text(totalOwedToYou, format: .currency(code: "USD"))
                        .figtreeFont(.semibold, size: 20)
                        .foregroundColor(.black)
                            
                    ForEach(expensesOwedToYou, id: \.id) { expense in
                        if let participantsList = participants[expense.id] {
                            ForEach(participantsList, id: \.id) { participant in
                                if let user = users[participant.userID] {
                                    SplitExpenseRow(
                                        title: expense.expenseDescription,
                                        fullName: user.fullName ?? user.username,
                                        amount: participant.amountDue,
                                        date: expense.creationDate
                                    )
                                }
                            }
                        }
                    }
                    
                } else {
                    Text("No one owes you")
                        .font(.caption)
                        .figtreeFont(.medium, size: 12)
                }
            }
        }
        .padding()
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
