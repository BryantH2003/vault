import SwiftUI

struct FriendDetailView: View {
    let friend: User
    let currentUserID: UUID
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FriendDetailViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileSection(friend: friend)
                    
                    if let latestExpense = viewModel.latestExpense {
                        LatestExpenseSection(expense: latestExpense)
                    }
                    
                    SplitExpensesSection(
                        splitExpenses: viewModel.splitExpenses,
                        isLoading: viewModel.isLoadingPayments,
                        currentUserID: currentUserID
                    )
                }
                .padding()
            }
            .navigationTitle("Friend Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.loadFriendDetails(friendID: friend.id, currentUserID: currentUserID)
        }
    }
}

// MARK: - Profile Section
private struct ProfileSection: View {
    let friend: User
    
    var body: some View {
        VStack(spacing: 12) {
            if let profileImageUrl = friend.profileImageUrl {
                AsyncImage(url: URL(string: profileImageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
            }
            
            Text(friend.fullName ?? "")
                .font(.title2)
                .bold()
            
            Text("@\(friend.username)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(friend.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Latest Expense Section
private struct LatestExpenseSection: View {
    let expense: Expense
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Latest Expense")
                .font(.headline)
                .padding(.bottom, 4)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(expense.title)
                        .font(.subheadline)
                        .bold()
                    Text(expense.transactionDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(String(format: "$%.2f", expense.amount))
                    .font(.headline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Split Expenses Section
private struct SplitExpensesSection: View {
    let splitExpenses: [(expense: SplitExpense, participant: SplitExpenseParticipant)]
    let isLoading: Bool
    let currentUserID: UUID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Split Expenses")
                .font(.headline)
                .padding(.bottom, 4)
            
            if isLoading {
                ProgressView()
            } else if splitExpenses.isEmpty {
                Text("No split expenses")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
                    .font(.subheadline)
                Text(splitExpense.creationDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(String(format: "$%.2f", splitExpense.totalAmount))
                    .font(.headline)
                
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
            // Load latest expense
            if let expenses = try? await expenseService.getExpenses(forUserID: friendID) {
                latestExpense = expenses.sorted(by: { $0.transactionDate > $1.transactionDate }).first
            }
            
            var allExpenses: [SplitExpense] = []
            
            // Load split expenses where current user is the payer
            let currentUserPaid = try await splitExpenseService.getSplitExpensesOthersOweUser(userID: currentUserID)
            
            // Filter for expenses where the friend is a participant
            for expense in currentUserPaid {
                let participants = try await splitExpenseParticipantService.getParticipants(forExpenseID: expense.id)
                if participants.contains(where: { $0.userID == friendID }) {
                    allExpenses.append(expense)
                }
            }
            
            // Load split expenses where friend is the payer
            let friendPaid = try await splitExpenseService.getSplitExpensesOthersOweUser(userID: friendID)
            
            // Filter for expenses where the current user is a participant
            for expense in friendPaid {
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
                    if expense.payerID == participant.userID {
                        expensesWithParticipants.append((
                            expense: expense,
                            participant: participant
                        ))
                    }
                }
            }
            
            // Sort by creation date, most recent first
            expensesWithParticipants.sort { $0.expense.creationDate > $1.expense.creationDate }
            
            print(expensesWithParticipants)
            
            await MainActor.run {
                self.splitExpenses = expensesWithParticipants
                self.isLoadingPayments = false
            }
            
        } catch {
            print("Error loading friend details: \(error.localizedDescription)")
            await MainActor.run {
                self.isLoadingPayments = false
            }
        }
    }
}
