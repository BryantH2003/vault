import SwiftUI

struct OutstandingPaymentsCard: View {
    let splitExpenses: [SplitExpense]
    let participants: [UUID: [SplitExpenseParticipant]]
    let users: [UUID: User]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Outstanding Payments")
                .font(.headline)
            
            if splitExpenses.isEmpty {
                Text("No outstanding payments")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(splitExpenses) { expense in
                    PaymentRow(
                        expense: expense,
                        participants: participants[expense.id] ?? [],
                        users: users
                    )
                    
                    if expense.id != splitExpenses.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

private struct PaymentRow: View {
    let expense: SplitExpense
    let participants: [SplitExpenseParticipant]
    let users: [UUID: User]
    
    var unpaidParticipants: [SplitExpenseParticipant] {
        participants.filter { $0.status == "pending" }
    }
    
    var totalOwed: Double {
        unpaidParticipants.reduce(into: 0) { $0 + $1.amountDue }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(expense.expenseDescription)
                    .fontWeight(.medium)
                Spacer()
                Text(totalOwed, format: .currency(code: "USD"))
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            
            if !unpaidParticipants.isEmpty {
                Text("Unpaid participants:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(unpaidParticipants, id: \.id) { participant in
                    if let user = users[participant.userID] {
                        HStack {
                            Text(user.username)
                                .font(.caption)
                            Spacer()
                            Text(participant.amountDue, format: .currency(code: "USD"))
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
} 
