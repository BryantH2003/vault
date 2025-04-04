import Foundation
import FirebaseFirestore

class DebugService {
    static let shared = DebugService()
    private let databaseService = FirebaseService.shared
    private let db = Firestore.firestore()
    
    func clearDatabase() async throws {
        // List of all collections to clear
        let collections = [
            "users",
            "expenses",
            "fixedExpenses",
            "incomes",
            "categories",
            "budgets",
            "savingsGoals",
            "friendships",
            "sharedDataSettings",
            "splitExpenses",
            "splitExpenseParticipants"
        ]
        
        // Delete all documents in each collection
        for collection in collections {
            try await deleteCollection(collection)
        }
    }
    
    private func deleteCollection(_ collectionPath: String) async throws {
        let batchSize = 100
        let collection = db.collection(collectionPath)
        
        while true {
            let query = collection.limit(to: batchSize)
            let snapshot = try await query.getDocuments()
            
            if snapshot.documents.isEmpty {
                break
            }
            
            let batch = db.batch()
            snapshot.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            try await batch.commit()
        }
    }
    
    func populateDummyData(for userId: UUID) async throws {
        // Create categories first as they're referenced by other entities
        let categories = try await createDummyCategories()
        
        // Create user's expenses
        try await createDummyExpenses(userId: userId, categories: categories)
        
        // Create fixed expenses
        try await createDummyFixedExpenses(userId: userId, categories: categories)
        
        // Create income entries
        try await createDummyIncome(userId: userId)
        
        // Create budget
        try await createDummyBudget(userId: userId, categories: categories)
        
        // Create savings goals
        try await createDummySavingsGoals(userId: userId)
        
        // Create friendships and shared data settings
        try await createDummyFriendships(userId: userId)
        
        // Create split expenses and participants
        try await createDummySplitExpenses(userId: userId)
    }
    
    private func createDummyCategories() async throws -> [Category] {
        let categories = [
            Category(id: UUID(), categoryName: "Groceries", fixedExpense: false),
            Category(id: UUID(), categoryName: "Rent", fixedExpense: true),
            Category(id: UUID(), categoryName: "Utilities", fixedExpense: true),
            Category(id: UUID(), categoryName: "Entertainment", fixedExpense: false)
        ]
        
        return try await withThrowingTaskGroup(of: Category.self) { group in
            for category in categories {
                group.addTask {
                    try await self.databaseService.createCategory(category)
                }
            }
            
            var result: [Category] = []
            for try await category in group {
                result.append(category)
            }
            return result
        }
    }
    
    private func createDummyExpenses(userId: UUID, categories: [Category]) async throws {
        let expenses = [
            Expense(id: UUID(), userID: userId, categoryID: categories[0].id, title: "Weekly Groceries", amount: 150.00, transactionDate: Date(), vendor: "Whole Foods"),
            Expense(id: UUID(), userID: userId, categoryID: categories[3].id, title: "Movie Night", amount: 30.00, transactionDate: Date().addingTimeInterval(-86400), vendor: "AMC"),
            Expense(id: UUID(), userID: userId, categoryID: categories[3].id, title: "Concert Tickets", amount: 120.00, transactionDate: Date().addingTimeInterval(-172800), vendor: "Ticketmaster")
        ]
        
        for expense in expenses {
            try await databaseService.createExpense(expense)
        }
    }
    
    private func createDummyFixedExpenses(userId: UUID, categories: [Category]) async throws {
        let fixedExpenses = [
            FixedExpense(id: UUID(), userID: userId, categoryID: categories[1].id, title: "Monthly Rent", amount: 2000.00, dueDate: Date().addingTimeInterval(86400 * 7), transactionDate: Date()),
            FixedExpense(id: UUID(), userID: userId, categoryID: categories[2].id, title: "Electricity Bill", amount: 150.00, dueDate: Date().addingTimeInterval(86400 * 14), transactionDate: Date()),
            FixedExpense(id: UUID(), userID: userId, categoryID: categories[2].id, title: "Internet Bill", amount: 80.00, dueDate: Date().addingTimeInterval(86400 * 21), transactionDate: Date())
        ]
        
        for fixedExpense in fixedExpenses {
            try await databaseService.createFixedExpense(fixedExpense)
        }
    }
    
    private func createDummyIncome(userId: UUID) async throws {
        let incomes = [
            Income(id: UUID(), userID: userId, source: "Salary", description: "Monthly Salary", amount: 5000.00, transactionDate: Date()),
            Income(id: UUID(), userID: userId, source: "Freelance", description: "Web Development Project", amount: 1000.00, transactionDate: Date().addingTimeInterval(-86400 * 7)),
            Income(id: UUID(), userID: userId, source: "Investment", description: "Dividend Payment", amount: 200.00, transactionDate: Date().addingTimeInterval(-86400 * 14))
        ]
        
        for income in incomes {
            try await databaseService.createIncome(income)
        }
    }
    
    private func createDummyBudget(userId: UUID, categories: [Category]) async throws {
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let budgets = [
            Budget(id: UUID(), userID: userId, categoryID: categories[0].id, title: "Grocery Budget", budgetAmount: 600.00, startDate: startOfMonth, endDate: endOfMonth),
            Budget(id: UUID(), userID: userId, categoryID: categories[3].id, title: "Entertainment Budget", budgetAmount: 300.00, startDate: startOfMonth, endDate: endOfMonth)
        ]
        
        for budget in budgets {
            try await databaseService.createBudget(budget)
        }
    }
    
    private func createDummySavingsGoals(userId: UUID) async throws {
        let savingsGoals = [
            SavingsGoal(id: UUID(), userID: userId, goalName: "Emergency Fund", targetAmount: 10000.00, currentAmount: 5000.00, targetDate: Date().addingTimeInterval(86400 * 365), creationDate: Date()),
            SavingsGoal(id: UUID(), userID: userId, goalName: "Vacation Fund", targetAmount: 3000.00, currentAmount: 1500.00, targetDate: Date().addingTimeInterval(86400 * 180), creationDate: Date()),
            SavingsGoal(id: UUID(), userID: userId, goalName: "New Laptop", targetAmount: 2000.00, currentAmount: 500.00, targetDate: Date().addingTimeInterval(86400 * 90), creationDate: Date())
        ]
        
        for goal in savingsGoals {
            try await databaseService.createSavingsGoal(goal)
        }
    }
    
    private func createDummyFriendships(userId: UUID) async throws {
        let friendIds = [UUID(), UUID(), UUID()]
        let friendships = [
            Friendship(id: UUID(), user1ID: userId, user2ID: friendIds[0], status: "accepted", actionUserID: UUID()),
            Friendship(id: UUID(), user1ID: userId, user2ID: friendIds[1], status: "pending", actionUserID: UUID()),
            Friendship(id: UUID(), user1ID: userId, user2ID: friendIds[2], status: "accepted", actionUserID: UUID())
        ]
        
        for (index, friendship) in friendships.enumerated() {
            try await databaseService.createFriendship(friendship)
            
            // Create shared data settings for accepted friendships
            if friendship.status == "accepted" {
                let settings = SharedDataSettings(
                    id: UUID(),
                    userID: userId,
                    friendID: friendIds[index],
                    canViewExpenses: true,
                    canViewSavings: index == 0,
                    canViewBudgets: index == 0
                )
                try await databaseService.createSharedDataSettings(settings)
            }
        }
    }
    
    private func createDummySplitExpenses(userId: UUID) async throws {
        let splitExpenses = [
            SplitExpense(id: UUID(), expenseDescription: "Dinner", totalAmount: 150.00, payerID: userId, creationDate: Date()),
            SplitExpense(id: UUID(), expenseDescription: "Movie Night", totalAmount: 90.00, payerID: userId, creationDate: Date().addingTimeInterval(-86400)),
            SplitExpense(id: UUID(), expenseDescription: "Groceries", totalAmount: 200.00, payerID: userId, creationDate: Date().addingTimeInterval(-172800))
        ]
        
        for splitExpense in splitExpenses {
            let createdSplitExpense = try await databaseService.createSplitExpense(splitExpense)
            
            // Create 2-3 participants for each split expense
            let participants = [
                SplitExpenseParticipant(id: UUID(), splitID: createdSplitExpense.id, userID: UUID(), amountDue: splitExpense.totalAmount / 3.0, status: "pending"),
                SplitExpenseParticipant(id: UUID(), splitID: createdSplitExpense.id, userID: UUID(), amountDue: splitExpense.totalAmount / 3.0, status: "pending"),
                SplitExpenseParticipant(id: UUID(), splitID: createdSplitExpense.id, userID: UUID(), amountDue: splitExpense.totalAmount / 3.0, status: "completed")
            ]
            
            for participant in participants {
                try await databaseService.createSplitExpenseParticipant(participant)
            }
        }
    }
} 
