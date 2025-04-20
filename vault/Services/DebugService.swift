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
            "splitExpenseParticipants",
            "vendors",
            "outstandingPayments"
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
    
    func createDummyData(for userID: UUID) async throws {
        print("Creating dummy data...")
        
        // Create categories first
        let categories = try await createDummyCategories()
        print("Created \(categories.count) categories")
        
        print()
        for category in categories {
            print(category)
        }
        print()
        
        // Create additional users (excluding the current user)
        let additionalUsers = try await createDummyUsers()
        print("Created \(additionalUsers.count) additional users")
        
        // Create expenses for the current user
        try await createDummyExpenses(forUserID: userID, categories: categories, otherUsers: additionalUsers)
        print("Created expenses")
        
        try await createDummyFixedExpenses(forUserID: userID, categories: categories)
        print("Created Fixed Expenses")
        
        try await createDummyIncome(forUserID: userID)
        print("Created incomes")
        
        try await createDummyBudget(forUserID: userID, categories: categories)
        print("Created budgets")
        
        try await createDummySavingsGoals(forUserID: userID)
        print("Created saving goals")
        
        // Create friendships between current user and dummy users
        try await createDummyFriendships(forUserID: userID, withUsers: additionalUsers)
        print("Created friendships")
        
        // Create split expenses between current user and all dummy users
//        try await createDummySplitExpenses(forUserID: userID, between: additionalUsers)
//        print("Created split expenses")
        
        // Create vendors
        try await createDummyVendors(categoryIDs: categories.map { $0.id })
        print("Created vendors")
        
        // Create outstanding payments
        try await createDummyOutstandingPayments(forUserID: userID, categories: categories)
        print("Created outstanding payments")
        
        print("Finished creating dummy data")
    }
    
    private func createDummyCategories() async throws -> [Category] {
        let categories = [
            Category(id: UUID(), categoryName: "Rent", fixedExpense: true),
            Category(id: UUID(), categoryName: "Electricity", fixedExpense: true),
            Category(id: UUID(), categoryName: "Internet", fixedExpense: true),
            Category(id: UUID(), categoryName: "Phone Bill", fixedExpense: true),
            Category(id: UUID(), categoryName: "Insurance", fixedExpense: true),
            Category(id: UUID(), categoryName: "Food", fixedExpense: false),
            Category(id: UUID(), categoryName: "Dessert", fixedExpense: false),
            Category(id: UUID(), categoryName: "Groceries", fixedExpense: false),
            Category(id: UUID(), categoryName: "Clothes", fixedExpense: false),
            Category(id: UUID(), categoryName: "Gas", fixedExpense: false),
            Category(id: UUID(), categoryName: "Gift", fixedExpense: false),
            Category(id: UUID(), categoryName: "Date", fixedExpense: false),
            Category(id: UUID(), categoryName: "Online Shopping", fixedExpense: false),
            Category(id: UUID(), categoryName: "Social", fixedExpense: false),
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
    
    private func createDummyExpenses(forUserID userId: UUID, categories: [Category], otherUsers: [User]) async throws {
        let categoryService = CategoryService()
        
        let expenses = try await [
            Expense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Groceries").id,
                title: "Weekly Groceries",
                amount: 150.00,
                transactionDate: Date(),
                vendor: "Whole Foods"),
            Expense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Date").id,
                title: "Movie Night",
                amount: 30.00,
                transactionDate: Date().addingTimeInterval(-86400),
                vendor: "AMC"),
            Expense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Social").id,
                title: "Concert Tickets",
                amount: 120.00,
                transactionDate: Date().addingTimeInterval(-172800),
                vendor: "Ticketmaster"),
            Expense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Food").id,
                title: "WINGGSS",
                amount: 220.00,
                transactionDate: Date().addingTimeInterval(-872800),
                vendor: "Wing Stop"),
            Expense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Groceries").id,
                title: "Groceries",
                amount: 50.00,
                transactionDate: Date().addingTimeInterval(-972800),
                vendor: "Kroger"),
            Expense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Dessert").id,
                title: "Boba",
                amount: 12.00,
                transactionDate: Date().addingTimeInterval(-1200),
                vendor: "Tiger Sugar"),
            Expense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Groceries").id,
                title: "Costco Groceries",
                amount: 87.00,
                transactionDate: Date().addingTimeInterval(-172800 * 12.3),
                vendor: "Costco"),
            Expense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Social").id,
                title: "Hang Out with Friends",
                amount: 37.00,
                transactionDate: Date().addingTimeInterval(-172800 * 15.4),
                vendor: "Volleyball"),
            Expense(
                id: UUID(),
                userID: otherUsers[0].id,
                categoryID: categoryService.getCategoryByName(name: "Food").id,
                title: "Chiptole",
                amount: 12.00,
                transactionDate: Date().addingTimeInterval(-172800 * 14.4),
                vendor: "Chiptole"),
            Expense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Food").id,
                title: "Chiptole",
                amount: 22.00,
                transactionDate: Date().addingTimeInterval(-172800 * 14.4),
                vendor: "Chi Cha")
        ]
        
        for expense in expenses {
            try await databaseService.createExpense(expense)
        }
    }
    
    private func createDummyFixedExpenses(forUserID userId: UUID, categories: [Category]) async throws {
        
        let categoryService = CategoryService()
        
        let fixedExpenses = try await [
            FixedExpense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Rent").id,
                title: "Monthly Rent",
                amount: 1500.00,
                dueDate: Date().addingTimeInterval(86400),
                isRecurring: true,
                recurrenceInterval: 1,
                recurringUnit: "Months"),
            FixedExpense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Internet").id,
                title: "Internet Bill",
                amount: 89.99,
                dueDate: Date().addingTimeInterval(86400),
                isRecurring: true,
                recurrenceInterval: 1,
                recurringUnit: "Months"),
            FixedExpense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Insurance").id,
                title: "Car Insurance",
                amount: 450.00,
                dueDate: Date().addingTimeInterval(86400),
                isRecurring: true,
                recurrenceInterval: 3,
                recurringUnit: "Months"),
            FixedExpense(
                id: UUID(),
                userID: userId,
                categoryID: categoryService.getCategoryByName(name: "Rent").id,
                title: "Monthly Rent",
                amount: 1530.00,
                dueDate: Date().addingTimeInterval(-86400 * 20),
                isRecurring: true,
                recurrenceInterval: 1,
                recurringUnit: "Months")
        ]
        
        for fixedExpense in fixedExpenses {
            try await databaseService.createFixedExpense(fixedExpense)
        }
    }
    
    private func createDummyIncome(forUserID userId: UUID) async throws {
        let incomes = [
            Income(id: UUID(), userID: userId, source: "Salary", description: "Monthly Salary", amount: 5000.00, transactionDate: Date()),
            Income(id: UUID(), userID: userId, source: "Freelance", description: "Web Development Project", amount: 1000.00, transactionDate: Date().addingTimeInterval(-86400 * 7)),
            Income(id: UUID(), userID: userId, source: "Investment", description: "Dividend Payment", amount: 200.00, transactionDate: Date().addingTimeInterval(-86400 * 20))
        ]
        
        for income in incomes {
            try await databaseService.createIncome(income)
        }
    }
    
    private func createDummyBudget(forUserID userId: UUID, categories: [Category]) async throws {
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let budgets = [
            Budget(id: UUID(), userID: userId, categoryID: categories[11].id, title: "Grocery Budget", budgetAmount: 600.00, startDate: startOfMonth, endDate: endOfMonth),
            Budget(id: UUID(), userID: userId, categoryID: categories[10].id, title: "Entertainment Budget", budgetAmount: 300.00, startDate: startOfMonth, endDate: endOfMonth)
        ]
        
        for budget in budgets {
            try await databaseService.createBudget(budget)
        }
    }
    
    private func createDummySavingsGoals(forUserID userId: UUID) async throws {
        let savingsGoals = [
            SavingsGoal(id: UUID(), userID: userId, goalName: "Emergency Fund", targetAmount: 10000.00, currentAmount: 5000.00, targetDate: Date().addingTimeInterval(86400 * 365), creationDate: Date()),
            SavingsGoal(id: UUID(), userID: userId, goalName: "Vacation Fund", targetAmount: 3000.00, currentAmount: 1500.00, targetDate: Date().addingTimeInterval(86400 * 180), creationDate: Date()),
            SavingsGoal(id: UUID(), userID: userId, goalName: "New Laptop", targetAmount: 2000.00, currentAmount: 500.00, targetDate: Date().addingTimeInterval(86400 * 90), creationDate: Date())
        ]
        
        for goal in savingsGoals {
            try await databaseService.createSavingsGoal(goal)
        }
    }
    
    private func createDummyFriendships(forUserID userID: UUID, withUsers users: [User]) async throws {
        print("Creating dummy friendships...")
        
        // Make current user friends with first dummy user
        if let firstUser = users.first {
            let friendship1 = Friendship(
                user1ID: userID,
                user2ID: firstUser.id,
                status: "Accepted",
                actionUserID: userID
            )
            try await databaseService.createFriendship(friendship1)
            print("Created friendship between current user and \(firstUser.username)")
            
            // If there's a second user, create a pending friend request
            if users.count >= 2 {
                let friendship2 = Friendship(
                    user1ID: userID,
                    user2ID: users[1].id,
                    status: "Pending",
                    actionUserID: userID
                )
                try await databaseService.createFriendship(friendship2)
                print("Created pending friendship between current user and \(users[1].username)")
            }
        }
    }
    
//    private func createDummySplitExpenses(forUserID userID: UUID, between users: [User]) async throws {
//        guard users.count >= 2 else {
//            print("Need at least 2 users to create split expenses")
//            return
//        }
//        
//        let splitExpenses = [
//            // Expenses where current user is the payer
//            SplitExpense(
//                expenseDescription: "Dinner at Italian Restaurant",
//                totalAmount: 150.00,
//                creatorID: users[0].id,
//                creationDate: Date()
//            ),
//            SplitExpense(
//                expenseDescription: "Groceries for Party",
//                totalAmount: 200.00,
//                creatorID: userID,
//                creationDate: Date().addingTimeInterval(-172800)
//            ),
//            
//            // Expenses where current user owes others
//            SplitExpense(
//                expenseDescription: "Movie Night",
//                totalAmount: 90.00,
//                creatorID: userID,
//                creationDate: Date().addingTimeInterval(-86400)
//            ),
//            SplitExpense(
//                expenseDescription: "Concert Tickets",
//                totalAmount: 300.00,
//                creatorID: users[1].id,
//                creationDate: Date().addingTimeInterval(-259200)
//            )
//        ]
//        
//        print("Creating \(splitExpenses.count) split expenses...")
//        
//        for splitExpense in splitExpenses {
//            let createdSplitExpense = try await databaseService.createSplitExpense(splitExpense)
//            let amountPerPerson = splitExpense.totalAmount
//            
//            if splitExpense.creatorID == userID {
//                // If user logged in is the payer that means the user logged in owes someone
//                var participant = SplitExpenseParticipant(
//                    splitID: createdSplitExpense.id,
//                    userID: users[0].id,
//                    amountDue: amountPerPerson / 3.0,
//                    status: "Pending"
//                )
//                try await databaseService.createSplitExpenseParticipant(participant)
//                
//                participant = SplitExpenseParticipant(
//                    splitID: createdSplitExpense.id,
//                    userID: users[1].id,
//                    amountDue: amountPerPerson / 3.0,
//                    status: "Pending"
//                )
//                try await databaseService.createSplitExpenseParticipant(participant)
//                
//            } else {
//                // Others paid, create participant for current user
//                let participant = SplitExpenseParticipant(
//                    splitID: createdSplitExpense.id,
//                    userID: userID,
//                    amountDue: amountPerPerson / 2.0,
//                    status: "Pending"
//                )
//                try await databaseService.createSplitExpenseParticipant(participant)
//            }
//            
//            print("Created split expense: \(splitExpense.expenseDescription) with participant")
//        }
//        print("Finished creating split expenses")
//    }
    
    // MARK: - Create Dummy Vendors
    private func createDummyVendors(categoryIDs: [UUID]) async throws {
        print("Creating dummy vendors...")
        
        let vendors = [
            Vendor(id: UUID(), vendorName: "Walmart", vendorLogoImageData: nil),
            Vendor(id: UUID(), vendorName: "Target", vendorLogoImageData: nil),
            Vendor(id: UUID(), vendorName: "Whole Foods", vendorLogoImageData: nil),
            Vendor(id: UUID(), vendorName: "AMC", vendorLogoImageData: nil),
        ]
        
        print("Creating \(vendors.count) dummy vendors...")
        for vendor in vendors {
            try await databaseService.createVendor(vendor)
        }
    }
    
    // MARK: - Create Dummy Users
    private func createDummyUsers() async throws -> [User] {
        print("Creating dummy users...")
        
        let users = [
            User(
                username: "john.doe",
                email: "john.doe@example.com",
                fullName: "John Doe",
                employmentStatus: "Employed",
                netPaycheckIncome: 5000,
                profileImageUrl: nil,
                monthlyIncome: 6000,
                monthlySavingsGoal: 1500,
                monthlySpendingLimit: 3000,
                userStatus: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            User(
                username: "jane.smith",
                email: "jane.smith@example.com",
                fullName: "Jane Smith",
                employmentStatus: "Self-Employed",
                netPaycheckIncome: 6000,
                profileImageUrl: nil,
                monthlyIncome: 7000,
                monthlySavingsGoal: 2000,
                monthlySpendingLimit: 3500,
                userStatus: "Going broke",
                createdAt: Date(),
                updatedAt: Date()
            ),
            User(
                username: "mike.wilson",
                email: "mike.wilson@example.com",
                fullName: "Mike Wilson",
                employmentStatus: "Employed",
                netPaycheckIncome: 4500,
                profileImageUrl: nil,
                monthlyIncome: 5500,
                monthlySavingsGoal: 1200,
                monthlySpendingLimit: 2800,
                userStatus: "Need more cash",
                createdAt: Date(),
                updatedAt: Date()
            ),
            User(
                username: "sarah.johnson",
                email: "sarah.johnson@example.com",
                fullName: "Sarah Johnson",
                employmentStatus: "Freelancer",
                netPaycheckIncome: 5500,
                profileImageUrl: nil,
                monthlyIncome: 6500,
                monthlySavingsGoal: 1800,
                monthlySpendingLimit: 3200,
                userStatus: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        print("Creating \(users.count) dummy users...")
        var createdUsers: [User] = []
        for user in users {
            let createdUser = try await databaseService.createUser(user)
            createdUsers.append(createdUser)
        }
        
        return createdUsers
    }
    
    // MARK: - Create Dummy Outstanding Payments
    private func createDummyOutstandingPayments(forUserID: UUID, categories: [Category]) async throws {
        print("Creating dummy outstanding payments...")
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        let payments = [
            OutstandingPayment(
                userID: forUserID,
                categoryID: categories[0].id,
                title: "Car Loan",
                amount: 1500.00,
                dueDate: Date().addingTimeInterval(86400 * 7),
                description: "Car loan payment",
                isPaid: false,
                priority: .high
            ),
            OutstandingPayment(
                userID: forUserID,
                categoryID: categories[1].id,
                title: "Vacation Flights",
                amount: 89.99,
                dueDate: Date().addingTimeInterval(86400 * 14),
                description: "Owe mom for tickets",
                isPaid: false,
                priority: .medium
            ),
            OutstandingPayment(
                userID: forUserID,
                categoryID: categories[2].id,
                title: "House Mortage",
                amount: 150.00,
                dueDate: Date().addingTimeInterval(86400 * 21),
                description: "Mortage on the hosuse",
                isPaid: false,
                priority: .low
            )
        ]
        
        print("Creating \(payments.count) outstanding payments...")
        for payment in payments {
            try await databaseService.createOutstandingPayment(payment)
            print("Created outstanding payment: \(payment.title)")
        }
        print("Finished creating outstanding payments")
    }
} 

