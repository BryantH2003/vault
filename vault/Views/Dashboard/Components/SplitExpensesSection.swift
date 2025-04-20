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
            ForEach(splitExpenses.indices, id: \.self) { index in
                let expenseData = splitExpenses[index]
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
                        .splitExpenseStatusTagsStyle(status: participants[0].status)
                    
                } else {
                    
                    Text(String(format: "$%.2f", splitExpense.totalAmount))
                        .cardRowAmountStyle()
                    
                    if getParticipantsPaymentStatusPending() > 0 {
                        Text("Pending \(getParticipantsPaymentStatusPaid())/\(participants.count)")
                            .splitExpenseStatusTagsStyle(status: "pending")
                    } else {
                        Text("Paid")
                            .splitExpenseStatusTagsStyle(status: "paid")
                    }
                }
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
