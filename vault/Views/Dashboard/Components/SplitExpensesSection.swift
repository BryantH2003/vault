//
//  SplitExpensesSectionFriendDetail.swift
//  vault
//
//  Created by Bryant Huynh on 4/16/25.
//
import SwiftUI

struct SplitExpensesSection: View {
    let splitExpenses: [(expense: SplitExpense, participants: [SplitExpenseParticipant])]
    let isLoading: Bool
    let currentUserID: UUID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Split Expenses")
                .cardTitleStyle()
            
            if isLoading {
                ProgressView()
            } else if splitExpenses.isEmpty {
                Text("No split expenses")
                    .secondaryTitleStyle()
            } else {
                ForEach(splitExpenses, id: \.expense.id) { expenseData in
                    SplitExpenseRow(
                        splitExpense: expenseData.expense,
                        participants: expenseData.participants,
                        currentUserID: currentUserID
                    )
                    
                    if expenseData.expense.id != splitExpenses.last?.expense.id {
                        Divider()
                    }
                }
            }
        }
        .friendDetailSectionCardStyle()
    }
}

private struct SplitExpenseRow: View {
    let splitExpense: SplitExpense
    let participants: [SplitExpenseParticipant]
    let currentUserID: UUID
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(splitExpense.expenseDescription)
                    .cardRowTitleStyle()
                Text(splitExpense.creationDate, style: .date)
                    .secondaryTitleStyle()
                
                if participants[0].userID == currentUserID {
                    Text("Paid by you")
                        .friendDetailPaidByTagStyle(textColor: .green)
                } else {
                    Text("Paid by \(participants.count) friends")
                        .friendDetailPaidByTagStyle(textColor: .blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                if participants[0].userID == currentUserID {
                    Text(String(format: "$%.2f", participants[0].amountDue))
                        .cardRowAmountStyle()
                    
                    Text(participants[0].status.capitalized)
                        .font(.caption)
                        .foregroundColor(statusColor(for: participants[0].status))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(for: participants[0].status).opacity(0.2))
                        .cornerRadius(8)
                } else {
                    Text(String(format: "$%.2f", splitExpense.totalAmount))
                        .cardRowAmountStyle()
                }
                
                
//                Text(participant.status.capitalized)
//                    .font(.caption)
//                    .foregroundColor(statusColor(for: participant.status))
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(statusColor(for: participant.status).opacity(0.2))
//                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending":
            return .orange
        case "paid":
            return .green
        case "declined":
            return .red
        default:
            return .gray
        }
    }
}
