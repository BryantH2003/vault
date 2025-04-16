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
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Latest Expense")
                                .cardTitleStyle()
                            
                            VStack(alignment: .center) {
                                Text("No transaction history.")
                                    .secondaryTitleStyle()
                            }
                        }
                    }
                    
                    SplitExpensesSectionFriendDetail(                        splitExpenses: viewModel.splitExpenses,
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
            
            Text(friend.fullName)
                .font(.title2)
                .bold()
            
            Text("@\(friend.username)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(friend.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .friendDetailSectionCardStyle()
    }
}

// MARK: - Latest Expense Section
private struct LatestExpenseSection: View {
    let expense: Expense
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Latest Expense")
                .cardTitleStyle()
            
            HStack {
                VStack(alignment: .leading) {
                    Text(expense.title)
                        .cardRowTitleStyle()
                    Text(expense.transactionDate, style: .date)
                        .secondaryTitleStyle()
                }
                
                Spacer()
                
                Text(String(format: "$%.2f", expense.amount))
                    .cardRowAmountStyle()
            }
        }
        .friendDetailSectionCardStyle()
    }
}

