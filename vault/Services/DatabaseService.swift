import Foundation
import FirebaseFirestore

class DatabaseService: ObservableObject {
    private let db = Firestore.firestore()
    
    // MARK: - Database Cleanup
    
    func cleanDatabase() async throws {
        // Delete all collections
        try await deleteCollection("users")
        try await deleteCollection("expenses")
        try await deleteCollection("savings")
        try await deleteCollection("outstandingPayments")
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
    
    // MARK: - Helper Methods
    
    private func generateUniqueKey() -> String {
        return UUID().uuidString
    }
    
    // MARK: - Dummy Data Population
    
    func populateDummyData(for userId: String) async throws {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        let year = components.year ?? calendar.component(.year, from: currentDate)
        let month = components.month ?? calendar.component(.month, from: currentDate)
        
        // Create dummy expenses
        let expenses = [
            Expense(
                uniqueKey: generateUniqueKey(),
                userId: userId,
                amount: 150.00,
                category: "Food",
                description: "Grocery Shopping",
                date: Date().addingTimeInterval(-86400 * 2), // 2 days ago
                isRecurring: false,
                recurringInterval: nil
            ),
            Expense(
                uniqueKey: generateUniqueKey(),
                userId: userId,
                amount: 45.00,
                category: "Transportation",
                description: "Gas",
                date: Date().addingTimeInterval(-86400 * 5), // 5 days ago
                isRecurring: false,
                recurringInterval: nil
            ),
            Expense(
                uniqueKey: generateUniqueKey(),
                userId: userId,
                amount: 1200.00,
                category: "Housing",
                description: "Rent",
                date: Date().addingTimeInterval(-86400 * 1), // 1 day ago
                isRecurring: true,
                recurringInterval: "monthly"
            ),
            Expense(
                uniqueKey: generateUniqueKey(),
                userId: userId,
                amount: 85.00,
                category: "Entertainment",
                description: "Movie Night",
                date: Date().addingTimeInterval(-86400 * 3), // 3 days ago
                isRecurring: false,
                recurringInterval: nil
            ),
            Expense(
                uniqueKey: generateUniqueKey(),
                userId: userId,
                amount: 185.00,
                category: "Food",
                description: "Cookie Contest",
                date: Date().addingTimeInterval(86400),
                isRecurring: false,
                recurringInterval: nil
            )
        ]
        
        // Create dummy savings for current month
        let savings = [
            Savings(
                uniqueKey: generateUniqueKey(),
                userId: userId,
                month: month,
                year: year,
                amount: 500.00
            ),
            Savings(
                uniqueKey: generateUniqueKey(),
                userId: userId,
                month: 3,
                year: year,
                amount: -200.00
            )
        ]
        
        // Create dummy outstanding payments
        let outstandingPayments = [
            OutstandingPayment(
                uniqueKey: generateUniqueKey(),
                userId: userId,
                title: "Car Loan",
                totalAmount: 25000.00,
                paidAmount: 5000.00,
                dueDate: nil,
                category: "Auto",
                notes: "Monthly car payment",
                createdAt: Date(),
                updatedAt: Date()
            ),
            OutstandingPayment(
                uniqueKey: generateUniqueKey(),
                userId: userId,
                title: "Student Loan",
                totalAmount: 15000.00,
                paidAmount: 3000.00,
                dueDate: Date().addingTimeInterval(86400 * 60), // 60 days from now
                category: "Education",
                notes: "Student loan payment",
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        // Add expenses to Firestore
        for expense in expenses {
            try await db.collection("expenses").addDocument(from: expense)
        }
        
        // Add savings to Firestore
        for saving in savings {
            try await db.collection("savings").addDocument(from: saving)
        }
        
        // Add outstanding payments to Firestore
        for payment in outstandingPayments {
            try await db.collection("outstandingPayments").addDocument(from: payment)
        }
    }
    
    // MARK: - Expenses
    
    func addExpense(_ expense: Expense) async throws {
        var newExpense = expense
        newExpense.uniqueKey = generateUniqueKey()
        try await db.collection("expenses").addDocument(from: newExpense)
    }
    
    func getExpenses(for userId: String, in dateRange: ClosedRange<Date>) async throws -> [Expense] {
        let snapshot = try await db.collection("expenses")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: dateRange.lowerBound)
            .whereField("date", isLessThanOrEqualTo: dateRange.upperBound)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Expense.self)
        }
    }
    
    func getTotalExpenses(for userId: String, in dateRange: ClosedRange<Date>) async throws -> Double {
        let expenses = try await getExpenses(for: userId, in: dateRange)
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Savings
    
    func addSavings(_ savings: Savings) async throws {
        var newSavings = savings
        newSavings.uniqueKey = generateUniqueKey()
        try await db.collection("savings").addDocument(from: newSavings)
    }
    
    func getSavings(for userId: String, month: Int, year: Int) async throws -> Savings? {
        let snapshot = try await db.collection("savings")
            .whereField("userId", isEqualTo: userId)
            .whereField("month", isEqualTo: month)
            .whereField("year", isEqualTo: year)
            .getDocuments()
        
        return try snapshot.documents.first?.data(as: Savings.self)
    }
    
    func updateSavings(_ savings: Savings) async throws {
        guard let id = savings.id else { throw DatabaseError.invalidId }
        let savingsRef = db.collection("savings").document(id)
        try await savingsRef.setData(from: savings)
    }
    
    // MARK: - Monthly Overview
    
    func getMonthlyOverview(for userId: String, date: Date) async throws -> (spent: Double, saved: Double, previousSpent: Double, previousSaved: Double) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let year = components.year ?? calendar.component(.year, from: date)
        let month = components.month ?? calendar.component(.month, from: date)
        
        // Get previous month
        let previousMonth = month == 1 ? 12 : month - 1
        let previousYear = month == 1 ? year - 1 : year
        
        // Get current month data
        async let currentExpenses = getExpenses(for: userId, in: date.startOfMonth...date.endOfMonth)
        async let currentSavings = getSavings(for: userId, month: month, year: year)
        
        // Get previous month data
        async let previousExpenses = getExpenses(for: userId, in: date.previousMonth.startOfMonth...date.previousMonth.endOfMonth)
        async let previousSavings = getSavings(for: userId, month: previousMonth, year: previousYear)
        
        // Wait for all async operations to complete
        let (currentExp, currentSav, previousExp, previousSav) = try await (currentExpenses, currentSavings, previousExpenses, previousSavings)
        
        // Calculate totals
        let currentSpent = currentExp.reduce(0) { $0 + $1.amount }
        let currentSaved = currentSav?.amount ?? 0
        let previousSpent = previousExp.reduce(0) { $0 + $1.amount }
        let previousSaved = previousSav?.amount ?? 0
        
        return (currentSpent, currentSaved, previousSpent, previousSaved)
    }
    
    // MARK: - Outstanding Payments
    
    func createOutstandingPayment(_ payment: OutstandingPayment) async throws {
        try await db.collection("outstandingPayments").document().setData(from: payment)
    }
    
    func updateOutstandingPayment(_ payment: OutstandingPayment, newAmount: Double) async throws {
        guard let documentId = payment.id else {
            throw DatabaseError.invalidDocumentId
        }
        var updatedPayment = payment
        updatedPayment.paidAmount = newAmount
        updatedPayment.updatedAt = Date()
        try await db.collection("outstandingPayments").document(documentId).setData(from: updatedPayment)
    }
    
    func deleteOutstandingPayment(_ paymentId: String) async throws {
        try await db.collection("outstandingPayments").document(paymentId).delete()
    }
    
    func getOutstandingPayments(for userId: String) async throws -> [OutstandingPayment] {
        let snapshot = try await db.collection("outstandingPayments")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            var payment = try document.data(as: OutstandingPayment.self)
            payment.id = document.documentID
            return payment
        }
    }
}

enum DatabaseError: Error {
    case invalidId
    case invalidDocumentId
} 
