//
//  AddExpenseViewModel.swift
//  vault
//
//  Created by Bryant Huynh on 4/11/25.
//
import SwiftUI

enum ExpenseType {
    case regular
    case fixed
    case shared
    
    enum SplitType {
        case even
        case custom
    }
}

@MainActor
class AddExpenseViewModel: ObservableObject {
    @Published var expenseType: ExpenseType = .regular
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
    
    // Fixed expense properties
    @Published var recurrenceInterval: Int = 1
    @Published var recurrenceUnit: RecurrenceUnit = .month
    
    // Split payment properties
    @Published var isSplitExpense = false
    @Published var selectedParticipants: Set<UUID> = []
    @Published var users: [User] = []
    @Published var isLoadingUsers = false
    @Published var searchQuery = ""
    @Published var filteredUsers: [User] = []
    @Published var splitType: ExpenseType.SplitType = .even
    @Published var showSplitSection = false
    
    // Custom split amounts
    @Published var currentUserAmount: Double = 0.0
    @Published private var participantAmounts: [UUID: Double] = [:]
    
    private let categoryService = CategoryService.shared
    private let expenseService = ExpenseService.shared
    private let splitExpenseService = SplitExpenseService.shared
    private let splitExpenseParticipantService = SplitExpenseParticipantService.shared
    private let userService = UserService.shared
    private let friendsService = FriendsService.shared
    private let fixedExpenseService = FixedExpenseService.shared
    
    enum RecurrenceUnit: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var filteredCategories: [Category] {
        switch expenseType {
        case .regular:
            return categories.filter { !$0.fixedExpense }
        case .fixed:
            return categories.filter { $0.fixedExpense }
        case .shared:
            return categories
        }
    }
    
    var isValid: Bool {
        !title.isEmpty &&
        amount > 0 &&
        selectedCategoryID != nil &&
        (expenseType != .shared || (!selectedParticipants.isEmpty && isCustomAmountsValid()))
    }
    
    func loadCategories() async {
        isLoadingCategories = true
        do {
            categories = try await categoryService.getAllCategories()
            if let firstCategory = filteredCategories.first {
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
            filteredUsers = []
        } else {
            filteredUsers = users.filter { user in
                user.username.localizedCaseInsensitiveContains(searchQuery) ||
                user.fullName.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
    
    func toggleParticipant(_ userID: UUID) {
        if !selectedParticipants.contains(userID) {
            selectedParticipants.insert(userID)
            showSplitSection = true // Show split section when first friend is added
            updateAmountsForSplitType()
        }
    }
    
    func removeParticipant(_ userID: UUID) {
        // Get the amount that was allocated to this participant before removing
        let allocatedAmount = participantAmounts[userID] ?? 0
        
        // Remove the participant
        selectedParticipants.remove(userID)
        participantAmounts.removeValue(forKey: userID)
        
        if splitType == .even {
            // Recalculate even split
            updateAmountsForSplitType()
        } else {
            // For custom split, we don't automatically redistribute the freed amount
            // It will show up in the remaining amount to allocate
        }
    }
    
    func updateAmountsForSplitType() {
        switch splitType {
        case .even:
            let totalParticipants = selectedParticipants.count + 1 // +1 for current user
            let amountPerPerson = (amount * 100).rounded() / 100 / Double(totalParticipants)
            
            currentUserAmount = amountPerPerson
            for participantID in selectedParticipants {
                participantAmounts[participantID] = amountPerPerson
            }
            
        case .custom:
            // Keep existing amounts if they're valid, otherwise reset to 0
            if !isCustomAmountsValid() {
                currentUserAmount = 0
                for participantID in selectedParticipants {
                    participantAmounts[participantID] = 0
                }
            }
        }
    }
    
    func distributeRemainingAmount() {
        let remainingAmount = amount - getTotalCustomAmounts()
        if remainingAmount <= 0 { return }
        
        // Find participants with 0 or no amount
        var participantsToDistribute: [UUID] = []
        for participantID in selectedParticipants {
            if participantAmounts[participantID] ?? 0 == 0 {
                participantsToDistribute.append(participantID)
            }
        }
        
        // Include current user if amount is 0
        let currentUserPlaceholder = UUID()
        if currentUserAmount == 0 {
            participantsToDistribute.append(currentUserPlaceholder)
        }
        
        if participantsToDistribute.isEmpty { return }
        
        // Distribute remaining amount evenly
        let amountPerPerson = (remainingAmount * 100).rounded() / 100 / Double(participantsToDistribute.count)
        
        for participantID in participantsToDistribute {
            if participantID == currentUserPlaceholder {
                currentUserAmount = amountPerPerson
            } else {
                participantAmounts[participantID] = amountPerPerson
            }
        }
    }
    
    func getParticipantAmountBinding(for userID: UUID) -> Binding<Double> {
        Binding(
            get: { self.participantAmounts[userID] ?? 0.0 },
            set: { newValue in
                // Limit to 2 decimal places
                self.participantAmounts[userID] = (newValue * 100).rounded() / 100
            }
        )
    }
    
    func getTotalCustomAmounts() -> Double {
        let participantsTotal = participantAmounts.values.reduce(0, +)
        return ((currentUserAmount + participantsTotal) * 100).rounded() / 100
    }
    
    func isCustomAmountsValid() -> Bool {
        if splitType == .even { return true }
        return abs(getTotalCustomAmounts() - amount) < 0.01
    }
    
    func saveExpense(userID: UUID) async -> Bool {
        guard let categoryID = selectedCategoryID else { return false }
        
        isSaving = true
        
        do {
            switch expenseType {
            case .regular:
                let expense = Expense(
                    userID: userID,
                    categoryID: categoryID,
                    title: title,
                    amount: amount,
                    transactionDate: date,
                    vendor: vendor.isEmpty ? nil : vendor
                )
                _ = try await expenseService.createExpense(expense)
                
            case .fixed:
                let fixedExpense = FixedExpense(
                    userID: userID,
                    categoryID: categoryID,
                    title: title,
                    amount: amount,
                    dueDate: date,
                    transactionDate: Date(),
                    recurrenceInterval: recurrenceInterval,
                    recurringUnit: recurrenceUnit.rawValue
                )
                _ = try await fixedExpenseService.createFixedExpense(fixedExpense)
                
            case .shared:
                let expense = Expense(
                    userID: userID,
                    categoryID: categoryID,
                    title: title,
                    amount: currentUserAmount,
                    transactionDate: date,
                    vendor: vendor.isEmpty ? nil : vendor
                )
                
                let savedExpense = try await expenseService.createExpense(expense)
                
                // Create split expense
                let splitExpense = SplitExpense(
                    expenseID: savedExpense.id,
                    expenseDescription: title,
                    totalAmount: amount,
                    creatorID: userID,
                    creationDate: date
                )
                
                let savedSplitExpense = try await splitExpenseService.createSplitExpense(splitExpense)
                
                // Create participants
                for participantID in selectedParticipants {
                    let participant = SplitExpenseParticipant(
                        splitID: savedSplitExpense.id,
                        userID: participantID,
                        amountDue: participantAmounts[participantID] ?? (amount / Double(selectedParticipants.count + 1)),
                        status: SplitExpenseParticipant.PaymentStatus.pending.rawValue
                    )
                    try await splitExpenseParticipantService.createParticipant(participant)
                }
            }
            
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isSaving = false
            return false
        }
    }
}
