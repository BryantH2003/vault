import SwiftUI

struct PaymentProgressCard: View {
    let title: String
    let totalAmount: Double
    let paidAmount: Double
    let dueDate: Date?
    let color: Color
    
    private var progressPercentage: Double {
        guard totalAmount > 0 else { return 0 }
        return min((paidAmount / totalAmount) * 100, 100)
    }
    
    private var progressColor: Color {
        if progressPercentage >= 100 {
            return .green
        } else if progressPercentage >= 25 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 4) {
                Text(title)
                    .bodyMediumStyle()
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(paidAmount.formatted(.currency(code: "USD")))
                    .bodySmallStyle()
                    .foregroundColor(.secondary)
                
                Text("/")
                    .bodySmallStyle()
                    .foregroundColor(.secondary)
                
                Text(totalAmount.formatted(.currency(code: "USD")))
                    .bodyMediumStyle()
                    .foregroundColor(.primary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 4)
                        .opacity(0.2)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(progressPercentage) * geometry.size.width / 100, geometry.size.width), height: 4)
                        .foregroundColor(progressColor)
                }
            }
            .frame(height: 4)
            
            HStack {
                Text(String(format: "%.0f%%", progressPercentage))
                    .captionStyle()
                    .foregroundColor(progressColor)
                
                Spacer()
                
                if let dueDate = dueDate {
                    Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .captionStyle()
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color, lineWidth: 1)
        )
    }
}

struct OutstandingPaymentCard: View {
    let payment: OutstandingPayment
    
    private var progressColor: Color {
        if payment.percentageCompleted >= 100 {
            return .green
        } else if payment.percentageCompleted >= 75 {
            return .blue
        } else if payment.percentageCompleted >= 50 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 4) {
                Text(payment.title)
                    .bodyMediumStyle()
                    .foregroundColor(.primary)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(payment.paidAmount.formatted(.currency(code: "USD"))) / \(payment.totalAmount.formatted(.currency(code: "USD")))")
                        .bodySmallStyle() // Use the same style for consistency
                        .foregroundColor(.primary)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 4)
                        .opacity(0.2)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(payment.percentageCompleted) * geometry.size.width / 100, geometry.size.width), height: 4)
                        .foregroundColor(progressColor)
                }
            }
            .frame(height: 4)
            
            HStack {
                Text(String(format: "%.0f%%", payment.percentageCompleted))
                    .captionStyle()
                    .foregroundColor(progressColor)
                
                Spacer()
                
                if let dueDate = payment.dueDate {
                    Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .captionStyle()
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.purple.opacity(0.65), lineWidth: 1)
        )
    }
}

struct RecentExpenseCard: View {
    let expense: Expense
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 4) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.description)
                        .bodyMediumStyle()
                        .foregroundColor(.primary)
                    
                    Text(expense.category)
                        .captionStyle()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(expense.amount.formatted(.currency(code: "USD")))
                        .bodyMediumStyle()
                        .foregroundColor(.primary)
                    
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                        .captionStyle()
                        .foregroundColor(.secondary)
                }
            }
            
            if expense.isRecurring {
                HStack(spacing: 4) {
                    Image(systemName: "repeat")
                        .font(.caption)
                    Text(expense.recurringInterval ?? "")
                        .captionStyle()
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color, lineWidth: 1)
        )
    }
} 
