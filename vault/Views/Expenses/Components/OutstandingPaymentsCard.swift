import SwiftUI

struct OutstandingPaymentsCard: View {
    let outstandingPayments: [OutstandingPayment]
    let users: [UUID: User]
    let categories: [UUID: Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Outstanding Payments")
                .cardTitleStyle()
            
            if outstandingPayments.isEmpty {
                Text("No outstanding payments")
                    .figtreeFont(.regular, size: 14)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                // Regular Outstanding Payments Section
                if !outstandingPayments.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bills & Recurring Payments")
                            .figtreeFont(.medium, size: 16)
                            .foregroundColor(.primary)
                        
                        ForEach(outstandingPayments.sorted { $0.dueDate < $1.dueDate }) { payment in
                            OutstandingPaymentRow(
                                payment: payment,
                                category: categories[payment.categoryID]
                            )
                            
                            if payment.id != outstandingPayments.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                
            }
        }
        .padding()
    }
}

private struct OutstandingPaymentRow: View {
    let payment: OutstandingPayment
    let category: Category?
    
    private var isOverdue: Bool {
        payment.dueDate < Date()
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(payment.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(String(format: "$%.2f", payment.amount))
                        .font(.headline)
                        .foregroundColor(payment.isPaid ? .green : .red)
                }
                
                HStack {
                    Text("Due: \(payment.dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if payment.isPaid {
                        Text("Paid")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Priority indicator
            HStack {
                PriorityBadge(priority: payment.priority)
                
                if isOverdue {
                    Text("OVERDUE")
                        .figtreeFont(.medium, size: 10)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(4)
                }
            }
        }
    }
}

private struct SplitExpenseRow: View {
    let expense: SplitExpense
    let participants: [SplitExpenseParticipant]
    let users: [UUID: User]
    
    private var totalOwed: Double {
        participants.reduce(0) { $0 + $1.amountDue }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.expenseDescription)
                        .figtreeFont(.medium, size: 14)
                    
                    if let payer = users[expense.payerID] {
                        Text("Paid by \(payer.username)")
                            .figtreeFont(.regular, size: 12)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(totalOwed, format: .currency(code: "USD"))
                        .figtreeFont(.semibold, size: 14)
                    
                    Text(expense.creationDate, style: .date)
                        .figtreeFont(.regular, size: 12)
                        .foregroundColor(.secondary)
                }
            }
            
            // Participants
            if !participants.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Participants:")
                        .figtreeFont(.regular, size: 12)
                        .foregroundColor(.secondary)
                    
                    ForEach(participants) { participant in
                        if let user = users[participant.userID] {
                            HStack {
                                Text(user.username)
                                    .figtreeFont(.regular, size: 12)
                                Spacer()
                                Text(participant.amountDue, format: .currency(code: "USD"))
                                    .figtreeFont(.regular, size: 12)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct PriorityBadge: View {
    let priority: OutstandingPayment.Priority
    
    var body: some View {
        Text(priority.rawValue.uppercased())
            .figtreeFont(.medium, size: 10)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priority.color)
            .cornerRadius(4)
    }
} 
