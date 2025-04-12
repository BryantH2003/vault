//
//  AddExpenseViewModel.swift
//  vault
//
//  Created by Bryant Huynh on 4/11/25.
//
import SwiftUI

@MainActor
class AddExpenseViewModel: ObservableObject {
    @Published var title = ""
    @Published var amount = 0.0
    @Published var vendor = ""
    @Published var date = Date()
    @Published var selectedCategoryID: UUID?
    @Published var categories: [Category] = []
    @Published var isLoadingCategories = false
    @Published var isSaving = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // Split payment properties
    @Published var isSplitExpense = false
    @Published var selectedParticipants: Set<UUID> = []
    @Published var users: [User] = []
    @Published var isLoadingUsers = false
    @Published var searchQuery = ""
    @Published var filteredUsers: [User] = []
    
    private let categoryService = CategoryService.shared
    private let expenseService = ExpenseService.shared
    private let splitExpenseService = SplitExpenseService.shared
    private let splitExpenseParticipantService = SplitExpenseParticipantService.shared
    private let userService = UserService.shared
    private let friendsService = FriendsService.shared
    
    var isValid: Bool {
        !title.isEmpty && amount > 0 && selectedCategoryID != nil &&
        (!isSplitExpense || (isSplitExpense && !selectedParticipants.isEmpty))
    }
    
    func loadCategories() async {
        isLoadingCategories = true
        do {
            categories = try await categoryService.getAllCategories()
            if let firstCategory = categories.first {
                selectedCategoryID = firstCategory.id
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoadingCategories = false
    }
    
    func loadFriends(forUserID userID: UUID) async {
        isLoadingUsers = true
        do {
            let friendships = try await friendsService.getFriendships(forUserID: userID)
            let acceptedFriendships = friendships.filter { $0.status == "Accepted" }
            
            // Get friend IDs
            let friendIDs = acceptedFriendships.map { friendship in
                friendship.user1ID == userID ? friendship.user2ID : friendship.user1ID
            }
            
            // Load friend details
            var loadedFriends: [User] = []
            for friendID in friendIDs {
                if let friend = try? await userService.getUser(id: friendID) {
                    loadedFriends.append(friend)
                }
            }
            
            await MainActor.run {
                self.users = loadedFriends
                self.filterUsers()
            }
        } catch {
            print("Error loading friends: \(error)")
            errorMessage = "Failed to load friends"
            showError = true
        }
        isLoadingUsers = false
    }
    
    func filterUsers() {
        if searchQuery.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { user in
                user.username.localizedCaseInsensitiveContains(searchQuery) ||
                (user.fullName?.localizedCaseInsensitiveContains(searchQuery) ?? false)
            }
        }
    }
    
    func saveExpense(userID: UUID) async -> Bool {
        guard isValid, let categoryID = selectedCategoryID else { return false }
        
        isSaving = true
        do {
            let expense = Expense(
                userID: userID,
                categoryID: categoryID,
                title: title,
                amount: amount,
                transactionDate: date,
                vendor: vendor.isEmpty ? nil : vendor
            )
            
            let savedExpense = try await expenseService.createExpense(expense)
            
            if isSplitExpense && !selectedParticipants.isEmpty {
                // Create split expense
                let splitExpense = SplitExpense(
                    expenseDescription: title,
                    totalAmount: amount,
                    payerID: userID,
                    creatorID: userID
                )
                
                let savedSplitExpense = try await splitExpenseService.createSplitExpense(splitExpense)
                
                // Calculate amount per person (including the creator)
                let totalParticipants = selectedParticipants.count + 1 // +1 for the creator
                let amountPerPerson = amount / Double(totalParticipants)
                
                // Create participants (including the creator)
                for participantID in selectedParticipants {
                    let participant = SplitExpenseParticipant(
                        splitID: savedSplitExpense.id,
                        userID: participantID,
                        amountDue: amountPerPerson,
                        status: SplitExpenseParticipant.PaymentStatus.pending.rawValue
                    )
                    try await splitExpenseParticipantService.createParticipant(participant)
                }
                
                // Add creator as a participant
                let creatorParticipant = SplitExpenseParticipant(
                    splitID: savedSplitExpense.id,
                    userID: userID,
                    amountDue: amountPerPerson,
                    status: SplitExpenseParticipant.PaymentStatus.paid.rawValue // Creator's portion is considered paid
                )
                try await splitExpenseParticipantService.createParticipant(creatorParticipant)
            }
            
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isSaving = false
            return false
        }
    }
    
    func toggleParticipant(_ userID: UUID) {
        if selectedParticipants.contains(userID) {
            selectedParticipants.remove(userID)
        } else {
            selectedParticipants.insert(userID)
        }
    }
}
