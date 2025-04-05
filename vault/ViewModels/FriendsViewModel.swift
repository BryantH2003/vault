import Foundation
import Combine

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [User] = []
    @Published var searchQuery = ""
    @Published var searchResults: [User] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published private var friendships: [Friendship] = []
    
    private var searchTask: Task<Void, Never>?
    private let userService = UserService.shared
    private let friendsService = FriendsService.shared
    private var currentUserID: UUID?
    
    var isSearching: Bool {
        !searchQuery.isEmpty
    }
    
    init() {
        // Set up search debounce
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self = self else { return }
                if !query.isEmpty {
                    self.searchTask?.cancel()
                    self.searchTask = Task {
                        await self.searchUsers(query: query)
                    }
                } else {
                    self.searchResults = []
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadFriends(forUserID: UUID) async {
        isLoading = true
        currentUserID = forUserID
        
        do {
            // Load friendships
            friendships = try await friendsService.getFriendships(forUserID: forUserID)
            
            // Get friend user IDs
            let friendIDs = friendships
                .filter { $0.status == "Accepted" }
                .map { $0.user1ID == forUserID ? $0.user2ID : $0.user1ID }
            
            // Load friend details
            var loadedFriends: [User] = []
            for friendID in friendIDs {
                if let friend = try? await userService.getUser(id: friendID) {
                    loadedFriends.append(friend)
                }
            }
            friends = loadedFriends
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    private func searchUsers(query: String) async {
        isLoading = true
        do {
            searchResults = try await userService.searchUsers(query: query)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    func getFriendshipStatus(for userID: UUID) -> FriendshipStatus {
        if friends.contains(where: { $0.id == userID }) {
            return .friend
        }
        
        if let friendship = friendships.first(where: {
            ($0.user1ID == userID || $0.user2ID == userID) &&
            $0.status == "Pending"
        }) {
            return .pending
        }
        
        return .notFriend
    }
    
    func sendFriendRequest(to userID: UUID) async {
        guard let currentUserID = currentUserID else { return }
        
        do {
            let friendship = try await friendsService.sendFriendRequest(from: currentUserID, to: userID)
            friendships.append(friendship)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
} 
