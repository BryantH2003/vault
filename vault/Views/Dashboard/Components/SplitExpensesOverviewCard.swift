import SwiftUI

struct SplitExpensesOverviewCard: View {
    let expensesYouOwe: [SplitExpense]
    let expensesOwedToYou: [SplitExpense]
    let participants: [UUID: [SplitExpenseParticipant]]
    let splitExpenses: [(expense: SplitExpense, participants: [SplitExpenseParticipant])]
    let isLoading: Bool
    let users: [UUID: User]
    let currentUserID: UUID
    @Environment(\.selectedDate) private var selectedDate
    
    private var filteredSplitExpenses: [(expense: SplitExpense, participants: [SplitExpenseParticipant])] {
        let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.year, .month], from: selectedDate)
        
        return splitExpenses.filter { expenseData in
            let expenseComponents = calendar.dateComponents([.year, .month], from: expenseData.expense.creationDate)
            
            // If the expense is from the selected month/year, include it
            if expenseComponents.year == selectedComponents.year && 
               expenseComponents.month == selectedComponents.month {
                return true
            }
            
            // If the expense is from a previous month/year and has pending participants, include it
            if expenseComponents.year! < selectedComponents.year! ||
               (expenseComponents.year! == selectedComponents.year! && 
                expenseComponents.month! < selectedComponents.month!) {
                // Check if any participant has a pending status
                return expenseData.participants.contains { $0.status.lowercased() == "pending" }
            }
            
            return false
        }
    }
    
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Split Expenses")
                .cardTitleStyle()
                
            if isLoading {
                ProgressView()
            } else if filteredSplitExpenses.isEmpty {
                
                // TODO: ADD BUTTON "Create Split Expense Now!"
                Text("No split expenses")
                    .secondaryTitleStyle()
                
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    SplitExpensesSection(
                        splitExpenses: filteredSplitExpenses,
                        isLoading: isLoading,
                        currentUserID: currentUserID)
                }
            }
        }
        .padding()
    }
}

private struct EnvironmentKeys {
    struct SelectedDateKey: EnvironmentKey {
        static let defaultValue: Date = Date()
    }
}

extension EnvironmentValues {
    var selectedDate: Date {
        get { self[EnvironmentKeys.SelectedDateKey.self] }
        set { self[EnvironmentKeys.SelectedDateKey.self] = newValue }
    }
}
