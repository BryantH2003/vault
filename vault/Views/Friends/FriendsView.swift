import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    let userID: UUID
    
    var body: some View {
        VStack {
            Text("My Friends")
                .cardTitleStyle()
            
            // Search bar
            SearchBar(text: $viewModel.searchQuery)
                .padding()
            
            if viewModel.isSearching {
                // Search results
                ScrollView {
                    VStack (spacing: 16){
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else if viewModel.searchResults.isEmpty {
                            Text("No users found")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(viewModel.searchResults) { user in
                                UserSearchRow(
                                    user: user,
                                    friendshipStatus: viewModel.getFriendshipStatus(for: user.id),
                                    onAddFriend: {
                                        Task {
                                            await viewModel.sendFriendRequest(to: user.id)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            } else {
                // Friends list
                ScrollView {
                    VStack (spacing: 8){
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else if viewModel.friends.isEmpty {
                            
                            // TODO: Add "Lets Add Friends" Button
                            Text("No friends yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(viewModel.friends) { friend in
                                FriendRow(friend: friend, currentUserID: userID)
                            }
                        }
                    }
                }
            }
        }
        .appBackground()
        .task {
            await viewModel.loadFriends(forUserID: userID)
        }
        .refreshable {
            await viewModel.loadFriends(forUserID: userID)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// Custom search bar view
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search users", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// Row view for search results
struct UserSearchRow: View {
    let user: User
    let friendshipStatus: FriendshipStatus
    let onAddFriend: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .cardRowTitleStyle()
                Text(user.email)
                    .secondaryTitleStyle()
            }
            
            Spacer()
            
            switch friendshipStatus {
            case .notFriend:
                Button(action: onAddFriend) {
                    Text("Add Friend")
                        .foregroundColor(.blue)
                }
            case .pending:
                Text("Pending")
                    .foregroundColor(.orange)
            case .friend:
                Text("Friend")
                    .foregroundColor(.green)
            }
        }
        .friendRowCardStyle()
    }
}

// Row view for friends list
struct FriendRow: View {
    let friend: User
    let currentUserID: UUID
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(friend.fullName)
                        .cardRowTitleStyle()
                    Text(friend.username)
                        .secondaryTitleStyle()
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if (friend.userStatus != nil) {
                        Text(friend.userStatus ?? "No user status")
                            .cardRowTitleStyle()
                    } else {
                        Text("No user status")
                            .secondaryTitleStyle()
                    }
                }
            }
            .friendRowCardStyle()
        }
        .sheet(isPresented: $showingDetail) {
            FriendDetailView(friend: friend, currentUserID: currentUserID)
        }
    }
}

enum FriendshipStatus {
    case notFriend
    case pending
    case friend
} 
