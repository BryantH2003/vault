import Foundation
import FirebaseFirestore

class DashboardViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var error: Error?
    
    let monthlyOverviewViewModel: MonthlyOverviewViewModel
    let outstandingPaymentsViewModel: OutstandingPaymentsViewModel
    let recentExpensesViewModel: RecentExpensesViewModel
    let savingsViewModel: SavingsViewModel
    
    private let databaseService: DatabaseService
    private let userId: String
    
    init(databaseService: DatabaseService, userId: String) {
        self.databaseService = databaseService
        self.userId = userId
        
        self.monthlyOverviewViewModel = MonthlyOverviewViewModel(databaseService: databaseService)
        self.outstandingPaymentsViewModel = OutstandingPaymentsViewModel(databaseService: databaseService)
        self.recentExpensesViewModel = RecentExpensesViewModel(databaseService: databaseService)
        self.savingsViewModel = SavingsViewModel(databaseService: databaseService)
    }
    
    func loadDashboardData() {
        isLoading = true
        error = nil
        
        Task {
            do {
                // Load data from each view model
                monthlyOverviewViewModel.loadMonthlyOverview(for: userId, date: selectedDate)
                outstandingPaymentsViewModel.loadOutstandingPayments(for: userId)
                recentExpensesViewModel.loadRecentExpenses(for: userId)
                savingsViewModel.loadSavings(for: userId)
                
                // Wait for all operations to complete
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay to allow data to load
                
                await MainActor.run {
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
    
    func updateDate(_ date: Date) {
        selectedDate = date
        monthlyOverviewViewModel.loadMonthlyOverview(for: userId, date: date)
        recentExpensesViewModel.updateSelectedDate(date)
        loadDashboardData()
    }
} 