import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var showingDatePicker = false
    @Published var outstandingPayments: [OutstandingPayment] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var spent: Double = 0
    @Published var saved: Double = 0
    @Published var previousSpent: Double = 0
    @Published var previousSaved: Double = 0
    @Published var recentExpenses: [Expense] = []
    
    private let databaseService: DatabaseService
    private let userId: String
    
    init(databaseService: DatabaseService = DatabaseService(), userId: String) {
        self.databaseService = databaseService
        self.userId = userId
    }
    
    @MainActor
    func loadMonthlyOverview() async {
        isLoading = true
        error = nil
        
        do {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: selectedDate)
            guard let startOfMonth = calendar.date(from: components),
                  let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid date"])
            }
            
            async let overviewTask = databaseService.getMonthlyOverview(for: userId, date: selectedDate)
            async let paymentsTask = databaseService.getOutstandingPayments(for: userId)
            async let expensesTask = databaseService.getExpenses(for: userId, in: startOfMonth...endOfMonth)
            
            let (overview, payments, expenses) = try await (overviewTask, paymentsTask, expensesTask)
            
            (self.spent, self.saved, self.previousSpent, self.previousSaved) = overview
            self.outstandingPayments = payments
            // Sort expenses by date in descending order and take the first 10
            self.recentExpenses = expenses
                .sorted { $0.date > $1.date }
                .prefix(10)
                .map { $0 }
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        Task {
            await loadMonthlyOverview()
        }
    }
} 