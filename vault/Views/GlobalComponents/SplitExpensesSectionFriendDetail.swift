//
//  SplitExpensesSection.swift
//  vault
//
//  Created by Bryant Huynh on 4/15/25.
//
import SwiftUI

struct SplitExpensesSectionFriendDetail: View {
    let splitExpenses: [(expense: SplitExpense, participant: SplitExpenseParticipant)]
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
                        participant: expenseData.participant,
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
    let participant: SplitExpenseParticipant
    let currentUserID: UUID
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(splitExpense.expenseDescription)
                    .cardRowTitleStyle()
                Text(splitExpense.creationDate, style: .date)
                    .secondaryTitleStyle()
                
                if (participant.userID == currentUserID) {
                    Text("Paid by you")
                        .friendDetailPaidByTagStyle(textColor: .green)
                } else {
                    Text("Paid by friend")
                        .friendDetailPaidByTagStyle(textColor: .blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(String(format: "$%.2f", participant.amountDue))
                    .cardRowAmountStyle()
                
                Text(participant.status.capitalized)
                    .font(.caption)
                    .foregroundColor(statusColor(for: participant.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: participant.status).opacity(0.2))
                    .cornerRadius(8)
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
