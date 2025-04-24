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

// TODO: REWORD DESIGN
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
