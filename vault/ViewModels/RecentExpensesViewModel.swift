import Foundation
import FirebaseFirestore

class RecentExpensesViewModel: ObservableObject {
    @Published var recentExpenses: [Expense] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let databaseService: DatabaseService
    private var selectedDate: Date
    
    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
        self.selectedDate = Date()
    }
    
    func loadRecentExpenses(for userId: String) {
        isLoading = true
        error = nil
        
        Task {
            do {
                // Get the start and end of the selected month
                let calendar = Calendar.current
                let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
                let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
                
                let expenses = try await databaseService.getExpenses(for: userId, in: startDate...endDate)
                await MainActor.run {
                    // Take only the first 10 expenses (they're already sorted by date descending)
                    self.recentExpenses = Array(expenses.prefix(10))
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
    }
} 