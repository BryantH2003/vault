//
//  FriendDetailViewModel.swift
//  vault
//
//  Created by Bryant Huynh on 4/15/25.
//
import SwiftUI

@MainActor
class FriendDetailViewModel: ObservableObject {
    @Published var latestExpense: Expense?
    @Published var splitExpenses: [(expense: SplitExpense, participant: SplitExpenseParticipant)] = []
    @Published var isLoadingPayments = false
    
    private let expenseService = ExpenseService.shared
    private let splitExpenseService = SplitExpenseService.shared
    private let splitExpenseParticipantService = SplitExpenseParticipantService.shared
    
    func loadFriendDetails(friendID: UUID, currentUserID: UUID) async {
        isLoadingPayments = true
        
        do {

// MARK: LATEST EXPENSE
            
            // Load latest expense
            if let expenses = try? await expenseService.getExpenses(forUserID: friendID) {
                latestExpense = expenses.sorted(by: { $0.transactionDate > $1.transactionDate }).first
            }

    // --------------------------------------------------------------

// MARK: SPLIT EXPENSE
            
            var allExpenses: [SplitExpense] = []
            
            // Load split expenses where current user is the payer
            let expensesYouOwe = try await splitExpenseService.getSplitExpensesOthersOweUser(userID: currentUserID)
            
            // Filter for expenses where the friend is a participant
            for expense in expensesYouOwe {
                let participants = try await splitExpenseParticipantService.getParticipants(forExpenseID: expense.id)
                if participants.contains(where: { $0.userID == friendID }) {
                    allExpenses.append(expense)
                }
            }
            
            // Load split expenses where friend is the payer
            let expensesOtherOweYou = try await splitExpenseService.getSplitExpensesOthersOweUser(userID: friendID)
            
            // Filter for expenses where the current user is a participant
            for expense in expensesOtherOweYou {
                let participants = try await splitExpenseParticipantService.getParticipants(forExpenseID: expense.id)
                if participants.contains(where: { $0.userID == currentUserID }) {
                    allExpenses.append(expense)
                }
            }
            
            
            // Load participants for each split expense
            var expensesWithParticipants: [(expense: SplitExpense, participant: SplitExpenseParticipant)] = []
            
            for expense in allExpenses {
                let participants = try await splitExpenseParticipantService.getParticipants(forExpenseID: expense.id)
                
                var relevantParticipant: SplitExpenseParticipant?
                
                for participant in participants {
                    if participant.userID == currentUserID || participant.userID == friendID {
                        expensesWithParticipants.append((
                            expense: expense,
                            participant: participant
                        ))
                    }
                }
            }
            
            // Sort by creation date, most recent first
            expensesWithParticipants.sort { $0.expense.creationDate > $1.expense.creationDate }
            
            await MainActor.run {
                self.splitExpenses = expensesWithParticipants
                self.isLoadingPayments = false
            }
    
    // --------------------------------------------------------------

            
        } catch {
            print("Error loading friend details: \(error.localizedDescription)")
            await MainActor.run {
                self.isLoadingPayments = false
            }
        }
    }
}
