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
            ForEach(splitExpenses, id: \.expense.id) { expenseData in
                SplitExpenseRow(
                    splitExpense: expenseData.expense,
                    participants: expenseData.participants,
                    currentUserID: currentUserID
                )
            }
        }
    }
}

private struct SplitExpenseRow: View {
    let splitExpense: SplitExpense
    let participants: [SplitExpenseParticipant]
    let currentUserID: UUID

    private let userService = UserService.shared
    
    @State private var splitExpenseCreator: User?
    
    func getParticipantsPaymentStatusPending() -> Int {
        var numPending = 0
        
        for participant in participants {
            if participant.status ==  "Pending" {
                numPending += 1
            }
        }
        
        return numPending
    }
    
    func getParticipantsPaymentStatusPaid() -> Int {
        var numPaid = 0
        
        for participant in participants {
            if participant.status ==  "Paid" {
                numPaid += 1
            }
        }
        
        return numPaid
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(splitExpense.expenseDescription)
                    .cardRowTitleStyle()
                Text(splitExpense.creationDate, style: .date)
                    .secondaryTitleStyle()
                
                if participants[0].userID == currentUserID {
                    if let creatorName = splitExpenseCreator?.fullName {
                        Text("You owe: \(creatorName)")
                            .friendDetailPaidByTagStyle(textColor: .green)
                    }
                } else {
                    Text("\(participants.count) friends owe you")
                        .friendDetailPaidByTagStyle(textColor: .blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                
                if participants.count <= 1 {
                    
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
                    
                    if getParticipantsPaymentStatusPending() > 0 {
                        Text("Pending \(getParticipantsPaymentStatusPaid())/\(participants.count)")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.orange.opacity(0.2))
                            .cornerRadius(8)
                    } else {
                        Text("Paid")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.green.opacity(0.2))
                            .cornerRadius(8)
                    }
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
        .task {
            do {
                splitExpenseCreator = try await userService.getUser(id: splitExpense.creatorID)
            } catch {
                print("Error loading creator: \(error)")
            }
        }
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
